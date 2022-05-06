-- 判定文件是否存在
local function file_exists(path)
    local file = io.open(path, "r")
    return file ~= nil and file:close()
end

local res = file_exists(ngx.var.request_filename)
local data = "false"
if (res) then
	data = "true"
end
ngx.header.content_type="application/json; charset=utf-8"
ngx.say('{"success":true,"data":'..data..',"traceId":"'..ngx.var.request_id..'"}')
ngx.exit(ngx.HTTP_OK) --直接返回200
