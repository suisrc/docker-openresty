-- 修正，代理服务器域名解析问题
if lan_domain == nil then 
    lan_domain = "."..os.getenv("LUA_PROXY_LAN_M") -- 读取环境变量
    ngx.log(ngx.ERR, "lan_domain:", lan_domain)
    -- "."标识没有取到环境变量，不对局域网域名处理
end
if lan_domain == "." then return end -- 不需要修复

-- 本地域名，不处理
if ngx.var.proxy_http_host == "localhost" then 
    return
end

-- 局域网域名,不好含"."
if string.find(ngx.var.proxy_http_host, ".", 1, true) == nil then
    ngx.var.proxy_http_host = ngx.var.proxy_http_host..lan_domain
    return
end

-- 已.svc结尾
if string.sub(ngx.var.proxy_http_host, -4) == ".svc" then
    ngx.var.proxy_http_host = ngx.var.proxy_http_host..".cluster.local"
    return
end