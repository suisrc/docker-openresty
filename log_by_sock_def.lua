-- log_by_lua
if logger_disable == nil then logger_disable = os.getenv("LUA_SYSLOG_TYPE") == "disable" end
if logger_disable then return end            -- 日志记录器已被禁用
if ngx.var.uri == "/healthz" then return end -- 忽略健康检查接口

-- 移除了用户信息部分内容
local cjson = require "cjson"
local logger = require "resty.socket.logger"
if not logger.initted() then
    local ok, err = logger.init{
        host      = os.getenv("LUA_SYSLOG_HOST") or "127.0.0.1",
        port      = tonumber(os.getenv("LUA_SYSLOG_PORT")) or 5144,
        sock_type = os.getenv("LUA_SYSLOG_TYPE") or "udp",
        -- flush after each log, >1会发生日志丢失
        flush_limit= 1,
        -- 缓存越界，丢弃当前消息, 20MB，1048576=1MB
        drop_limit= 20971520,
        -- 连接池， 平均每个连接1MB
        pool_size = 20,
        -- 发送尝试失败次数, 只重试一次，防止阻塞
        max_retry_times = 1,
    }
    if not ok then
        ngx.log(ngx.ERR, "failed to initialize the logger: ", err)
        return
    end
end
-- 日志级别信息
local msg = {}

msg.traceId = ngx.var.http_x_request_id
msg.clientId = ngx.var.http_x_client_id or ngx.var.cookie__xc
msg.remoteIp = ngx.var.http_x_real_ip or ngx.var.realip_remote_addr
msg.userAgent = ngx.var.http_user_agent or ""
msg.referer = ngx.var.http_referer or ""
msg.flowId = ngx.var.arg_flow or ""
-- 登录用户级基本信息在这里不做记录
-- 请求鉴权匹配的策略，记录请求通过接口的策略
msg.matchPolicys = ngx.var.http_x_request_sky_policys or ngx.ctx.sub_headers and ngx.ctx.sub_headers["X-Request-Sky-Policys"] or ""
-- 请求描述
msg.scheme = ngx.var.scheme or ""
msg.host = ngx.var.proxy_p_host or ngx.var.host or ""
msg.path = ngx.var.proxy_p_uri or ngx.var.request_uri or ""
msg.method = ngx.var.request_method or ""
msg.status = ngx.var.status or ""
msg.startTime = os.date("%Y-%m-%dT%H:%M:%S", ngx.req.start_time()) or ""
msg.reqTime = ngx.var.request_time or ""
-- msg.reqTime = ngx.now() - msg.startTime
-- 服务
msg.tags = ngx.var.proxy_tags or ""
msg.serviceName = ngx.var.proxy_http_host or ngx.var.proxy_host or ngx.ctx.sub_proxy_host or ""
msg.serviceAddr = ngx.var.upstream_addr or ngx.ctx.sub_upstream_addr or ""
msg.serviceAuth = ngx.ctx.sub_proxy_host or ""

msg.clientName = loc_area_name or ""
msg.clientAddr = ngx.var.remote_addr or "" -- 请求者
if msg.clientAddr == "127.0.0.1" and loc_area_ip ~= nil and loc_area_ip ~= "" then msg.clientAddr = loc_area_ip end
msg.clientAddr = msg.clientAddr..":"..ngx.var.remote_port

-- msg.reqHeaders = ngx.req.raw_header(true) or ""
-- msg.reqCookies = ngx.var.http_cookie or ""
local rpsky = "x-request-sky-"  -- 包含认证敏感信息，不能对外开放
local rpsrv = "x-service-name"  -- 应答的服务器
msg.reqHeaders = ""
msg.reqHeader2s = ""
for k, v in pairs(ngx.req.get_headers()) do
    -- authorization, cookie中包含用户登录的敏感信息，不能对外开放
    if k == 'authorization' or k == "cookie" or string.sub(k, 1, #rpsky) == rpsky then
        if type(v) == "table" then
            for _, v1 in pairs(v) do
                msg.reqHeader2s = msg.reqHeader2s..k..": "..v1.."\n"
            end
        else
            msg.reqHeader2s = msg.reqHeader2s..k..": "..v.."\n"
        end
    else
        if type(v) == "table" then
            for _, v1 in pairs(v) do
                msg.reqHeaders = msg.reqHeaders..k..": "..v1.."\n"
            end
        else
            msg.reqHeaders = msg.reqHeaders..k..": "..v.."\n"
        end
    end
    if k == rpsrv then
        msg.responder = v
    end
end
msg.respHeaders = ""
for k, v in pairs(ngx.resp.get_headers()) do
    if type(v) == "table" then
        for _, v1 in pairs(v) do
            msg.respHeaders = msg.respHeaders..k..": "..v1.."\n"
        end
    else
        msg.respHeaders = msg.respHeaders..k..": "..v.."\n"
    end
    if k == rpsrv then
        msg.responder = v
    end
end
-- 参数
local ajson = "application/json"
local axxml = "application/xml"
local rqtyp = ngx.var.http_content_type
if rqtyp and string.sub(rqtyp, 1, #ajson) == ajson then
    msg.reqBody = ngx.var.request_body -- json格式的参数被记录
elseif rqtyp and string.sub(rqtyp, 1, #axxml) == axxml then
    msg.reqBody = ngx.var.request_body -- xml格式的参数被记录
else
    msg.reqBody = "" -- 其他格式的参数不被记录
end
-- 响应
--local rtype = ngx.resp.get_headers()["content-type"]
--local rptyp = ngx.var.upstream_http_content_type
--if rptyp and string.sub(rptyp, 1, #ajson) == ajson then
if ngx.ctx.resp_body ~= nil then
    -- body_filter_by_lua
    -- 每次请求的响应输出在ngx.arg[1]中；而是否到eof则标记在ngx.arg[2]中
    msg.respBody = ngx.ctx.resp_body   --json格式的返回结果被记录
else
    msg.respBody = "" -- 不记录返回结果
end
msg.result2 = "成功"
if msg.status >= "400" then
    msg.result2 = "错误"
elseif msg.status >= "300" then
    msg.result2 = "重定向"
elseif msg.respBody ~= nil and msg.respBody ~= "" and string.sub(msg.respBody, 1, 1) == "{" then
    -- 解析 json, 注意：只支持json返回值内容分析
    local resj = cjson.decode(msg.respBody)
    -- 返回值可能存在不规范情况，即不是json类型， (not resj.success)
    if type(resj) == "table" and resj.success == false then
        if resj.showType == 9 then
            msg.result2 = "重定向"
        else
            msg.result2 = "错误"
        end
    end
end
-- table to json
local msg_str = cjson.encode(msg)
local bytes, err = logger.log(msg_str)
if err then
    ngx.log(ngx.ERR, "failed to log message: ", err)
    return
end