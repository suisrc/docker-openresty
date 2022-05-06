--两个table合并
local function merge_table(t1,t2)
    for k,v in pairs(t2) do
        t1[k] = v
    end
    return t1
end

--检验请求的sign签名是否正确
--params:传入的参数值组成的table
--secret:项目secret，根据key找到secret
local function sign_check(params,secret)
    --判断参数是否为空，为空报异常
    if params == nil or next(params) == nil then
        return false,"参数为空"
    end

    if secret == nil then
        return false,"密钥为空"
    end

    local sign0 = params["Signature"]
    if sign0 == nil then
        return false,"签名参数为空"
    end

    --是否存在时间戳的参数
    local time0 = params["Expires"]
    if time0 == nil then
        return false,"时间参数为空"
    end

    -- 时间戳有没有过时，允许10秒误差
    local time_now = ngx.now() -- 秒级
    if time_now - time0 > 10 then
        return false,"资源已过期"
    end

    local keys, tmp = {}, {}
    --提出全部的键名并按字符顺序排序
    for k, _ in pairs(params) do
        if k ~= "Signature" then
            keys[#keys+1] = k
        end

    end
    table.sort(keys)
    --根据排序好的键名依次读取值并拼接字符串成key=value&key=value
    for _,k in pairs(keys) do
        if type(params[k]) == "string" or type(params[k]) == "number" then
            tmp[#tmp+1] = k .. "=" .. tostring(params[k])
        end
    end

    --将salt添加到最后，计算正确的签名sign值并与传入的sign签名对比
    local sign_str = ngx.var.uri .. "?" .. table.concat(tmp, "&") .. "&"
    local sign1 = ngx.md5(sign_str..secret)
    if sign0 ~= sign1 then
        --若是签名错误返回错误信息并记录日志
        local mess="签名错误: sign_0="..sign0..", sign_1="..sign1.."; sign_str="..sign_str.."{secret}"
        ngx.log(ngx.ERR, mess)
        return false,mess
        -- return false,"签名错误"
    end
    return true
end

if ngx.var.uri == '/favicon.ico' then
	return
end

local params = {}

local get_args = ngx.req.get_uri_args()
merge_table(params,get_args)

-- ngx.req.read_body()
-- local post_args = ngx.req.get_post_args()
-- merge_table(params,post_args)

--根据keyID到后台服务获取secret
--平台分配给某客户端类型的KeyID
--local key0 = params["AccessKeyId"];
local secret = ngx.var.secret
local cres,mess = sign_check(params,secret)

if not cres then
    ngx.header.content_type="application/json; charset=utf-8"
    ngx.say('{"success":false,"errorCode":"B_FILE_SIGN-ERROR","errorMessage":"'..mess..'","traceId":"'..ngx.var.request_id..'"}')
    return ngx.exit(ngx.HTTP_FORBIDDEN) --直接返回403
end
