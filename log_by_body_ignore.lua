-- 不处理body内容

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
ngx.ctx.resp_buffered_ignore = true
ngx.ctx.resp_body = "# 响应内容已经被标记,忽略"