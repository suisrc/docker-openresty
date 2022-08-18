-- 图片水印
-- image/watermark,t_15,rotate_30,text_5byg5LiJMjHlubQ45pyINOaXpSAgICAgICAgICA=,fill_1
-- https://help.aliyun.com/document_detail/44957.html
-- t: 指定图片水印或水印文字的透明度。	[0,100], 默认值: 100, 表示透明度100%（不透明）。
-- g: 指定水印在图片中的位置。	nw: 左上, north: 中上, ne: 右上,west: 左中, center: 中部, east: 右中, sw: 左下, south: 中下, se: 右下,默认值
-- x: 指定水印的水平边距, 即距离图片边缘的水平距离。这个参数只有当水印位置是左上、左中、左下、右上、右中、右下才有意义。	[0,4096] 默认值: 10 单位: 像素px
-- y: 指定水印的垂直边距,即距离图片边缘的垂直距离, 这个参数只有当水印位置是左上、中上、右上、左下、中下、右下才有意义。	[0,4096] 默认值: 10 单位: px
-- voffset: 指定水印的中线垂直偏移。当水印位置在左中、中部、右中时,可以指定水印位置根据中线往上或者往下偏移。	[-1000,1000] 默认值: 0 单位: px
-- 
-- text: 指定文字水印的文字内容,文字内容需进行Base64编码。详情请参见水印编码。	Base64编码之前中文字符串的最大字节长度为64个字符。
-- type: 指定文字水印的字体,字体名称需进行Base64编码。	支持的字体及字体编码详情请参见文字类型编码对应表。 默认值: wqy-zenhei（ 编码后的值为d3F5LXplbmhlaQ）
-- color: 指定文字水印的文字颜色,参数值为RGB颜色值。	RGB颜色值,例如: 000000表示黑色,FFFFFF表示白色。 默认值: 000000 黑色
-- size: 指定文字水印的文字大小。(0,1000] 默认值: 40 单位: px
-- shadow: 指定文字水印的阴影透明度。[0,100] 默认值: 0,表示没有阴影。
-- rotate: 指定文字顺时针旋转角度。[0,360] 默认值: 0,表示不旋转。
-- fill: 指定是否将文字水印铺满原图。1: 表示将文字水印铺满原图。0: 表示不将文字水印铺满全图,默认值

-- image: 用于指定作为图片水印Object的完整名称，Object名称需进行Base64编码。详情请参见水印编码。例如，作为图片水印的Object为Bucket内image目录下的panda.png，则需要编码的内容为image/panda.png，编码后的字符串为aW1hZ2UvcGFuZGEucG5n。
-- P: 指定图片水印按照原图的比例进行缩放，取值为缩放的百分比。如设置参数值为10，如果原图为100×100， 当原图变成了200×200，则图片水印大小为20×20。
-- T: 指定图片水印或水印文字的透明度。	[0,100], 默认值: 100, 表示透明度100%（不透明）。当文字和图片共存时候，图片专用参数
-- O: 指定图片载入方式，默认：Multiply(乘积), Dissolve(融合), Copy(覆盖)...

-- graphicsmagick
local b64 = require("ngx.base64")
local ffi = require "ffi"
local gmw = require "gmwand"
local lib = gmw.lib
---------------------------------------------------------------------------------------------------
local font_names = {
    ['sarasa-b'] = '/usr/share/fonts/truetype/sarasa-gothic/sarasa-gothic-sc-bold.ttf',
    ['sarasa'] = '/usr/share/fonts/truetype/sarasa-gothic/sarasa-gothic-sc-regular.ttf'
}
-- Watermark
local function fix_params(kv)
    if not (kv['text'] or kv['image']) then
        ngx.header.content_type="application/json; charset=utf-8"
        ngx.say('{"success":false,"errorCode":"B_FILE_NOT-CXT","errorMessage":"内容不存在","traceId":"'..ngx.var.request_id..'"}')
        ngx.exit(ngx.HTTP_BAD_REQUEST) -- 没有指定水印内容，无法处理
    end
    if (kv['image']) then 
        kv['image'] = ngx.var.realpath_root ..'/'.. ngx.decode_base64(kv['image'])
        if not gmw.file_exists(kv['image']) then -- 水印文件不存在
            ngx.header.content_type="application/json; charset=utf-8"
            ngx.say('{"success":false,"data":"'..kv['image']..'","errorCode":"B_FILE_NOT-IMG",\
            "errorMessage":"水印文件不存在","traceId":"'..ngx.var.request_id..'"}')
            ngx.exit(ngx.HTTP_BAD_REQUEST)
        end
    end

    -- if (kv['text']) then kv['text'] = ngx.decode_base64(kv['text']) end
    if (kv['text']) then kv['text'] = b64.decode_base64url(kv['text']) end
    if (kv['t']) then kv['t'] = tonumber(kv['t']) / 100.0 end
    if (kv['x']) then kv['x'] = tonumber(kv['x']) end
    if (kv['y']) then kv['y'] = tonumber(kv['y']) end
    if (kv['voffset']) then kv['voffset'] = tonumber(kv['voffset']) end
    if (kv['size']) then kv['size'] = tonumber(kv['size']) end
    if (kv['shadow']) then kv['shadow'] = tonumber(kv['shadow']) / 100 end -- 未使用水印阴影
    if (kv['rotate']) then kv['rotate'] = tonumber(kv['rotate']) end
    if (kv['fill']) then kv['fill'] = tonumber(kv['fill']) end
    if (kv['type']) then kv['type'] = b64.decode_base64url(kv['type']) end
    if (kv['color']) then kv['color'] = '#'..kv['color'] end
    if (kv['fill']) then kv['fill'] = tonumber(kv['fill']) end
    if (kv['P']) then kv['P'] = tonumber(kv['P']) end
    if (kv['T']) then kv['T'] = tonumber(kv['T']) / 100.0 end
end

local function get_draw_wand(kv)
    local d_wand = ffi.gc(lib.MagickNewDrawingWand(), lib.MagickDestroyDrawingWand)

    lib.MagickDrawSetFillOpacity(d_wand, kv['t'] or 0.5) -- opactity
    -- if kv['P'] then lib.MagickDrawScale(d_wand, kv['P'], kv['P']) end -- scale

    local p_wand = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
    lib.PixelSetColor(p_wand, kv['color'] or "black")
    -- lib.PixelSetColor(p_wand, kv['color'] or "grey75") -- #BEBEBE
    lib.MagickDrawSetFillColor(d_wand, p_wand) -- fill coler

    lib.MagickDrawSetFont(d_wand, font_names[kv['type'] or 'Arial']) -- 'Arial' or font_names['sarasa']
    lib.MagickDrawSetFontSize(d_wand, kv['size'] or 40) -- size

    -- lib.MagickDrawRotate(d_wand, kv['rotate'] or 0) -- rotate
    -- lib.MagickDrawAnnotation(d_wand, x, y, kv['text']) -- text
    return d_wand
end

-- kv, gap: 间距， fill: 是否支持fill
local function get_x_y_g(kv, gap, fill)
    local padding = 8
    -- g -> gravity ----------------------------------------------
    local x, y = kv['voffset'] or kv['x'] or 0, kv['y'] or 0
    local g
    if kv['fill'] == 1 and fill then
        x = padding -- fill tile kv[x],kv[y]无效
        y = padding + gap
        g = lib.NorthWestGravity
    elseif kv['g'] == 'nw' then
        x = x + padding
        y = y + padding + gap
        g = lib.NorthWestGravity
    elseif kv['g'] == 'n' or kv['g'] == 'north' then
        y = y + padding + gap
        g = lib.NorthGravity
    elseif kv['g'] == 'ne' then
        x = x + padding
        y = y + padding + gap
        g = lib.NorthEastGravity
    elseif kv['g'] == 'w' or kv['g'] == 'west' then
        x = x + padding
        g = lib.WestGravity
    elseif kv['g'] == 'c' or kv['g'] == 'center' then
        g = lib.CenterGravity
    elseif kv['g'] == 'e' or kv['g'] == 'east' then
        x = x + padding
        g = lib.EastGravity
    elseif kv['g'] == 'sw' then
        x = x + padding
        y = y + padding
        g = lib.SouthWestGravity
    elseif kv['g'] == 's' or kv['g'] == 'south' then
        y = y + padding
        g = lib.SouthGravity
    else -- elseif kv['g'] == 'se' then -- default
        x = x + padding
        y = y + padding
        g = lib.SouthEastGravity
    end
    return x, y, g
end

-- watermark
return function(wand, kv)
    fix_params(kv)
    if kv['image'] then
        -- lib.MagickSetImageCompose(wand, lib.DissolveCompositeOp)
        local c_wand = gmw.read(kv['image'])

        -- local b_wand = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
        -- lib.PixelSetColor(b_wand, "black")
        -- lib.MagickSetImageBackgroundColor(c_wand, b_wand)

        local cop = lib[(kv['O'] or 'Multiply') .. 'CompositeOp']
        local cwidth, cheight = lib.MagickGetImageWidth(c_wand), lib.MagickGetImageHeight(c_wand)
        if kv['P'] then
            cwidth, cheight = cwidth * kv['P']/100, cheight * kv['P']/100
            lib.MagickScaleImage(c_wand, cwidth, cheight)
            -- lib.MagickResizeImage(c_wand, cwidth, cheight, lib.UndefinedFilter, 1.0) 
        end
        if kv['T'] or kv['t'] then
            local p_wand = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
            lib.PixelSetOpacity(p_wand, 1 - (kv['T'] or kv['t'] or 1))
            lib.MagickColorizeImage(c_wand, p_wand, p_wand)
        end
        local width, height = lib.MagickGetImageWidth(wand), lib.MagickGetImageHeight(wand)
        local x, y, g = get_x_y_g(kv, 0, false)
        if g == lib.NorthWestGravity then
            -- x = x
        elseif g == lib.NorthGravity then
            x = x + width / 2 - cwidth / 2
        elseif g == lib.NorthEastGravity then
            x = - x + width - cwidth
        elseif g == lib.WestGravity then
            y = y + height / 2 - cheight / 2
        elseif g == lib.CenterGravity then
            x = x + width / 2 - cwidth / 2
            y = y + height / 2 - cheight / 2
        elseif g == lib.EastGravity then
            x = - x + width - cwidth
            y = y + height / 2 - cheight / 2
        elseif g == lib.SouthWestGravity then
            y = - y + height - cheight
        elseif g == lib.SouthGravity then
            x = x + width / 2 - cwidth / 2
            y = - y + height - cheight
        else -- elseif g == lib.SouthEastGravity then -- default
            x = - x + width - cwidth
            y = - y + height - cheight
        end
        lib.MagickCompositeImage(wand, c_wand, cop, x, y)
    end
    if kv['text'] then
        local d_wand = get_draw_wand(kv)
        local x, y, g = get_x_y_g(kv, lib.MagickDrawGetFontSize(d_wand), true)
        local r = kv['rotate'] or 0
        if kv['fill'] == 1 then
            -- 满屏处理
            local mw, mh = lib.MagickGetImageWidth(wand), lib.MagickGetImageHeight(wand)
            -- metrics: 0 字符宽度 1 字符高度 2 升序 3 降序 4 文本宽度 5 文本高度 6 最大水平前进
            local ms = lib.MagickQueryFontMetrics(wand, d_wand, kv['text'])
            local mwl = ms[4] * math.cos(math.rad(r)) + 20
            local mhl = ms[5] * 2 + ms[4] * math.sin(math.rad(r)) / 2
            for h = y, tonumber(mh), mhl do
                for w = 0, tonumber(mw), mwl do
                    lib.MagickAnnotateImage(wand, d_wand, w, h, r, kv['text'])
                end
            end
        else
            -- lib.MagickDrawImage(wand, d_wand)
            lib.MagickDrawSetGravity(d_wand, g)
            lib.MagickAnnotateImage(wand, d_wand, x, y, r, kv['text'])
        end
    end
end