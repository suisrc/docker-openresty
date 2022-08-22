-- 修正，代理服务器域名解析问题
if lan_domain == nil then 
    lan_domain = "."..os.getenv("LUA_PROXY_LAN_M") or false
end
if lan_domain then return end -- 不需要修复

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