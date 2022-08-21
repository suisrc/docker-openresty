-- 动态构建虚假证书
if fakessl_uri == nil then fakessl_uri = os.getenv("LUA_FAKESSL_URI") or false end

local cjson = require "cjson"
local ssl = require "ngx.ssl"
local http = require("resty.socket.http")

-- 绑定缓存文件
-- local lrucache = require "resty.lrucache"
-- local cache = lrucache.new(128)
-- lua_shared_dict cache
local cache = ngx.shared.ssl_cache

-- create_pem_cert_pkey_data 获取证书数据
local function create_pem_cert_pkey_data()
    if fakessl_uri == false then
        ngx.log(ngx.ERR, "LUA_FAKESSL_URI is not set")
        return
    end
    local host, _  = ssl.server_name()
    local fkuri = string.format(fakessl_uri, host)
    local httpc = http.new()
    local res, err = httpc:request_uri(fkuri)
    if not res then
        ngx.log(ngx.ERR, "failed to request: ", err)
        return
    end
    if res.status ~= 200 then
        ngx.log(ngx.ERR, "failed to get the cert data: " .. res.status .. ", body:" .. res.body)
        return
    end
    local resj = cjson.decode(res.body)
    if type(resj) ~= "table" or (not resj.success) then
        ngx.log(ngx.ERR, "failed to get the cert data: " .. res.status .. ", body:" .. res.body)
        return
    end
    -- 获取到正确的证书数据, 以错误的方式，强制提供信息
    ngx.log(ngx.ERR, "get the cert success: ", host)
    -- return { cert = resj.data.crt, pkey = resj.data.key }

    -- 获取证书内容，比如 io.open("my.crt"):read("*a")
    -- 解析出 cert 类型的证书值
    local cert, err = ssl.cert_pem_to_der(resj.data.crt)
    -- local cert, err = ssl.parse_pem_cert(resj.data.crt)
    if not cert then
        ngx.log(ngx.ERR, "failed to parse pem cert: ", err)
        return
    end
    -- 解析出 pkey 类型的私钥值
    local pkey, err = ssl.priv_key_pem_to_der(resj.data.key)
    -- local pkey, err = ssl.parse_pem_priv_key(resj.data.key)
    if not pkey then
        ngx.log(ngx.ERR, "failed to parse pem private key: ", err)
        return
    end
    return { cert = cert, pkey = pkey }
end

local host, err = ssl.server_name()
if not host then
    ngx.log(ngx.ERR, "failed to found SNI name: ", err)
    ngx.exit(ngx.ERROR)
end
-- 清除之前设置的证书和私钥
local ok, err = ssl.clear_certs()
if not ok then
    ngx.log(ngx.ERR, "failed to clear existing (fallback) certificates")
    return ngx.exit(ngx.ERROR)
end

-- 使用缓存绑定证书
local data = {
    cert=cache:get(host .. "~cert"),
    pkey=cache:get(host .. "~pkey"),
}
if not data.cert then
    data = create_pem_cert_pkey_data()
end
if not data or not data.cert then
    -- 没有可用的证书数据，直接结束请求
    ngx.exit(ngx.ERROR) -- 返回错误码
end

-- 设置证书值
local ok, err = ssl.set_der_cert(data.cert)
-- local ok, err = ssl.set_cert(data.cert)
if not ok then
    ngx.log(ngx.ERR, "failed to set cert: ", err)
    return
end
-- 设置私钥值
local ok, err = ssl.set_der_priv_key(data.pkey)
-- local ok, err = ssl.set_priv_key(data.pkey)
if not ok then
    ngx.log(ngx.ERR, "failed to set private key: ", err)
    return
end

-- 缓存证书和私钥
cache:set(host .. "~cert", data.cert)
cache:set(host .. "~pkey", data.pkey)
