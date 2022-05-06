package.path = '/etc/nginx/conf.d/image?.lua;'..package.path
-- graphicsmagick
local gmw = require "gmwand"

local resize = require "_resize"
local watermark = require "_watermark"

-- ipairs vs pairs
local function process_image(wand, kvs)
    for _, kv in pairs(kvs) do
        if kv[1] == 'watermark' then watermark(wand, kv)
        elseif kv[1] == 'resize' then resize(wand, kv)
        end
    end
end
---------------------------------------------------------------------------------------------------
-- 开始执行
local filename = ngx.var.request_filename

-- check image file
if not gmw.file_exists(filename) then
    ngx.header.content_type="application/json; charset=utf-8"
    ngx.say('{"success":false,"data":"'..ngx.var.uri..'","errorCode":"B_FILE_NOT-FOUND","errorMessage":"文件不存在","traceId":"'..ngx.var.request_id..'"}')
    ngx.exit(ngx.HTTP_NOT_FOUND)
end

-- 处理参数
-- resize,w_500,h_500,m_fill/watermark,t_15,rotate_30,text_5byg5LiJMjH
local kvs = gmw.split_param(ngx.var.process_params)

-- 加载
local wand = gmw.read(filename)
-- 处理
process_image(wand, kvs)
-- 保存 quality,q_90
local quality = 100
if kvs['quality'] and kvs['quality']['q'] then quality = tonumber(kvs['quality']['q']) end
local data = gmw.save(wand, quality)

ngx.print(data)
ngx.exit(ngx.HTTP_OK)