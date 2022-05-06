-- 图片缩放
-- image/resize,w_500,h_500,m_fill
-- m:  指定缩放的模式。
--     1.lfit:默认值,等比缩放,缩放图限制为指定w与h的矩形内的最大图片。
--     2.mfit:等比缩放,缩放图为延伸出指定w与h的矩形框外的最小图片。
--     3.fill:将原图等比缩放为延伸出指定w与h的矩形框外的最小图片,之后将超出的部分进行居中裁剪。
--     4.pad:将原图缩放为指定w与h的矩形内的最大图片,之后使用指定颜色居中填充空白部分。
--     5.fixed:固定宽高,强制缩放。
-- w:  指定目标缩放图的宽度。 [1,4096]
-- h:  指定目标缩放图的高度。 [1,4096]

-- 如: gm convert file.jpg -resize 100x100 -quality 100 file-100x100.jpg
-- 由于压缩后比较模糊,默认图片质量为100,请根据自己情况修改quality
-- https://github.com/openresty/lua-nginx-module
-- https://luajit.org/ext_ffi_api.html
-- https://github.com/suisrc/docker-openresty/blob/graphicsmagick/graphicsmagick/README.md
-- https://help.aliyun.com/document_detail/44688.html
-- https://www.cnblogs.com/JohnABC/p/6182915.html

local gmw = require "gmwand"

-- resize
return function(wand, kv)
    -- 转换类型
    if (kv['w']) then kv['w'] = tonumber(kv['w']) end
    if (kv['h']) then kv['h'] = tonumber(kv['h']) end
    -- 变更尺寸
    gmw.size(wand, kv['w'], kv['h'])
end
