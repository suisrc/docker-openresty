-- 修正，代理服务器域名解析问题

-- 通过/etc/hosts文件获取局域网IP
if loc_area_ip == nil then
    local f_host = io.open("/etc/hosts")
    if f_host then -- 获取本地局域网IP
        for line in f_host:lines() do
            local ip, host = string.match(line, "^(%d+%.%d+%.%d+%.%d+)%s+([%w-_%.]*)")
            if host ~= nil and string.find(host, "localhost") == nil then 
                loc_area_ip = ip
                loc_area_name = host
                break  
            end
        end
        f_host:close()
    end
    if loc_area_ip == nil then  loc_area_ip = "" end
    ngx.log(ngx.ERR, "loc_area_ip:"..loc_area_ip..", loc_area_name:"..loc_area_name..";")
end

if lan_domain == nil then 
    lan_domain = "."..(os.getenv("LUA_PROXY_LAN_M") or "") -- 读取环境变量
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