-- body_filter_by_lua
-- https://github.com/openresty/lua-nginx-module/issues/1092

-- body采集主要是给日志系统提供数据，如果禁用日志系统，则不记录body
if logger_disable == nil then logger_disable = os.getenv("LUA_SYSLOG_TYPE") == "disable" end
if logger_disable then return end

-- 处理子请求和请求的body数据
if ngx.is_subrequest then
    local chunk, eof = ngx.arg[1], ngx.arg[2]
    if eof then
        -- 抽取子请求内容，记录日志
        ngx.ctx.sub_proxy_host = ngx.var.proxy_host
        ngx.ctx.sub_upstream_addr = ngx.var.upstream_addr
    end
    return -- 不记录子请求
end

if ngx.ctx.resp_buffered_ignore then
    return -- 操作内容忽略
end

-- #######################################################################
if ngx.ctx.resp_buffered == nil then
    local ajson = "application/json"
    local axxml = "application/xml"
    local rtype = ngx.var.upstream_http_content_type
    if rtype == nil then
        rtype = ngx.resp.get_headers()["content-type"]
    end
    -- ngx.log(ngx.ERR, "content_type: ", rtype) -- 非json和xml格式的body不记录
    if not (rtype ~= nil and (string.sub(rtype, 1, #ajson) == ajson or string.sub(rtype, 1, #axxml) == axxml)) then
        ngx.ctx.resp_buffered_ignore = true
        ngx.ctx.resp_body = "# 响应内容不是JSON/XML类型,忽略"
        return -- 只记录json/xml内容
    end
end
local chunk, eof = ngx.arg[1], ngx.arg[2]
-- ngx.log(ngx.ERR, "chunk: ", chunk)
-- 缓存记录resp_body内容
if chunk ~= nil and chunk ~= "" then
    -- 记录请求body内容
    -- 这种行为很容易导致LuaJIT发生GC，但是这确实是当前唯一解决方案
    ngx.ctx.resp_buffered = (ngx.ctx.resp_buffered or "")..chunk
end
-- resp_buffered超过2MB，则忽略 2 * 1024 * 1024 = 2097152 = 2 << 21
if ngx.ctx.resp_buffered ~= nil and #ngx.ctx.resp_buffered > 2097152 then
    ngx.ctx.resp_buffered_ignore = true
    ngx.ctx.resp_body = "# 响应内容大于2MB,忽略"
    return -- 内容超过2MB，忽略
end

if eof then
    -- 最后一次响应，合并所有数据
    ngx.ctx.resp_body = ngx.ctx.resp_buffered
    ngx.ctx.resp_buffered = nil
end


-- -- 获取当前响应数据
-- if ngx.ctx.resp_buffered == nil then
--     ngx.ctx.resp_buffered = {}
-- end
-- -- 如果非最后一次响应，将当前响应赋值
-- if chunk ~= nil and chunk ~= "" then
--     -- 非子请求，非空
--     table.insert(ngx.ctx.resp_buffered, chunk)
--     -- 将当前响应赋值为空，以修改后的内容作为最终响应
--     -- 注意，这里会导致无法进行流处理，只记录json数据
--     ngx.arg[1] = nil
-- end
-- -- 如果为最后一次响应，对所有响应数据进行处理
-- if eof then
--     -- 获取所有响应数据
--     local body = table.concat(ngx.ctx.resp_buffered)
--     ngx.ctx.resp_buffered = nil
--     -- 进行你所需要进行的处理
--     -- ... 此处可以增加敏感词检测等操作
--     -- 重新赋值响应数据，以修改后的内容作为最终响应
--     ngx.arg[1] = body
-- end