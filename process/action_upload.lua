-- https://nginx.org/en/docs/varindex.html
local upload = require "resty.upload"
local strhex = require "resty.string"
-- local cjson = require "cjson"

string.split = function(s,p)
    local rt = {}
    string.gsub(s,'[^'..p..']+', function(w) table.insert(rt, w) end)
    return rt
end

local function mkdirs(file)
  local dir = string.match(file, ".+/")
  if not dir then
    return false
  end
  os.execute("mkdir -p "..dir)
  return true
end

local function file_upload(form)
    local filename
    local filebody
    local filesave = false
    local realpath = ngx.var.request_filename
    while true do
        local typ, res, err = form:read()
        if not typ then
            return false,"表单内容不合法"
        end
        if typ == "header" then
            -- read filename from header
            if res[1] == "Content-Disposition" then
                -- form-data; name="testfilename"; filename="testfile.txt"
                local kvlist = string.split(res[2],';')
                for _, kv in ipairs(kvlist) do
                    if kv and kv:find("filename") then
                        filename = string.sub(string.split(kv, "=")[2], 2, -2)
                        filebody = io.open(realpath, "w+")
                        if not filebody and mkdirs(realpath) then
                            -- 尝试创建文件夹
                            filebody = io.open(realpath, "w+") -- 再次尝试打开
                        end
                        if not filebody then
                            return false,"文件目录不合法"
                        end
                    end
                end
            end
        elseif typ == "body" then
            if filebody then
                filebody:write(res)
            end
        elseif typ == "part_end" then
            if filebody then
                filebody:close()
                filebody = nil
            end
            filesave = true
        elseif typ == "eof" then
            break -- 跳出循环
        else
            return false,"表单内容不合法"
        end
    end
    if not filesave then
        return false,"文件异常关闭"
    end
    --local request_uri = "https://" .. ngx.var.host .. ngx.var.request_uri
    -- local filepath = string.sub(realpath, string.len(ngx.var.realpath_root) + 1)
    local filepath = ngx.var.uri
    -- local file_idx = ngx.md5(realpath)..ngx.encode_base64(ngx.sha1_bin(realpath))
    local file_idx = strhex.to_hex(ngx.md5_bin(realpath))..strhex.to_hex(ngx.sha1_bin(realpath))
    -- local file_idx = ngx.encode_base64(ngx.md5_bin(realpath)..ngx.sha1_bin(realpath))
    -- local file_idx = ngx.encode_base64(realpath)
    return true,'{"filename":"'..filename..'","filepath":"'..filepath..'","file_idx":"'..file_idx..'"}'
end

local chunk_size = 4096
local form, err = upload:new(chunk_size)

ngx.header.content_type="application/json; charset=utf-8"
if not form then
    ngx.say('{"success":false,"errorCode":"B_FILE_UPLOAD-ERROR","errorMessage":"表单内容错误","traceId":"'..ngx.var.request_id..'"}')
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

form:set_timeout(10000)
local cres,data = file_upload(form)

if not cres then
    ngx.say('{"success":false,"errorCode":"B_FILE_SIGN-ERROR","errorMessage":"'..data..'","traceId":"'..ngx.var.request_id..'"}')
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR) --直接返回403
end
ngx.say('{"success":true,"data":'..data..',"traceId":"'..ngx.var.request_id..'"}')
ngx.exit(ngx.HTTP_OK) --直接返回200
