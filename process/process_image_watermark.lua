-- 图片水印 (完成)
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

-- graphicsmagick
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
    if (kv['text']) then 
        kv['text'] = ngx.decode_base64(kv['text'])
    else
        ngx.header.content_type="application/json; charset=utf-8"
        ngx.say('{"success":false,"errorCode":"B_FILE_NOT-TEXT","errorMessage":"内容不存在","traceId":"'..ngx.var.request_id..'"}')
        ngx.exit(ngx.HTTP_BAD_REQUEST) -- 没有指定水印内容，无法处理
    end
    if (kv['t']) then kv['t'] = tonumber(kv['t']) / 100 end
    if (kv['x']) then kv['x'] = tonumber(kv['x']) end
    if (kv['y']) then kv['y'] = tonumber(kv['y']) end
    if (kv['voffset']) then kv['voffset'] = tonumber(kv['voffset']) end
    if (kv['size']) then kv['size'] = tonumber(kv['size']) end
    if (kv['shadow']) then kv['shadow'] = tonumber(kv['shadow']) / 100 end -- 未使用水印阴影
    if (kv['rotate']) then kv['rotate'] = tonumber(kv['rotate']) end
    if (kv['fill']) then kv['fill'] = tonumber(kv['fill']) end
    if (kv['type']) then kv['type'] = ngx.decode_base64(kv['type']) end
    if (kv['color']) then kv['color'] = '#'..kv['color'] end
    if (kv['fill']) then kv['fill'] = tonumber(kv['fill']) end
end

local function get_draw_wand(kv)
    local padding = 8
    local p_wand = ffi.gc(lib.NewPixelWand(), lib.DestroyPixelWand)
    lib.PixelSetColor(p_wand, kv['color'] or "black")
    -- lib.PixelSetColor(p_wand, kv['color'] or "grey75") -- #BEBEBE
    local d_wand = ffi.gc(lib.MagickNewDrawingWand(), lib.MagickDestroyDrawingWand)

    lib.MagickDrawSetFillOpacity(d_wand, kv['t'] or 0.5) -- opactity
    lib.MagickDrawSetFillColor(d_wand, p_wand) -- fill coler
    lib.MagickDrawSetFont(d_wand, font_names[kv['type']] or 'Arial') -- 'Arial' or font_names['sarasa']
    lib.MagickDrawSetFontSize(d_wand, kv['size'] or 40) -- size

    -- lib.MagickDrawRotate(d_wand, kv['rotate'] or 0) -- rotate
    -- g -> gravity ----------------------------------------------
    local x, y, r = kv['voffset'] or kv['x'] or 0, kv['y'] or 0, kv['rotate'] or 0
    if kv['fill'] == 1 then
        x = padding -- fill tile kv[x],kv[y]无效
        y = padding / 2 + lib.MagickDrawGetFontSize(d_wand)
        lib.MagickDrawSetGravity(d_wand, lib.NorthWestGravity)
    elseif kv['g'] == 'nw' then
        lib.MagickDrawSetGravity(d_wand, lib.NorthWestGravity)
        x = x + padding
        y = y + padding / 2 + lib.MagickDrawGetFontSize(d_wand)
    elseif kv['g'] == 'n' or kv['g'] == 'north' then
        lib.MagickDrawSetGravity(d_wand, lib.NorthGravity)
        y = y + padding / 2 + lib.MagickDrawGetFontSize(d_wand)
    elseif kv['g'] == 'ne' then
        lib.MagickDrawSetGravity(d_wand, lib.NorthEastGravity)
        x = x + padding
        y = y + padding / 2 + lib.MagickDrawGetFontSize(d_wand)
    elseif kv['g'] == 'w' or kv['g'] == 'west' then
        lib.MagickDrawSetGravity(d_wand, lib.WestGravity)
        x = x + padding
    elseif kv['g'] == 'c' or kv['g'] == 'center' then
        lib.MagickDrawSetGravity(d_wand, lib.CenterGravity)
    elseif kv['g'] == 'e' or kv['g'] == 'east' then
        lib.MagickDrawSetGravity(d_wand, lib.EastGravity)
        x = x + padding
    elseif kv['g'] == 'sw' then
        lib.MagickDrawSetGravity(d_wand, lib.SouthWestGravity)
        x = x + padding
        y = y + padding * 2
    elseif kv['g'] == 's' or kv['g'] == 'south' then
        lib.MagickDrawSetGravity(d_wand, lib.SouthGravity)
        y = y + padding * 2
    elseif kv['g'] == 'we' then
        lib.MagickDrawSetGravity(d_wand, lib.SouthEastGravity)
        x = x + padding
        y = y + padding * 2
    else 
        -- default -- kv[x],kv[y]无效
        lib.MagickDrawSetGravity(d_wand, lib.CenterGravity)
    end
    -- lib.MagickDrawAnnotation(d_wand, x, y, kv['text'])
    -- lib.MagickDrawRotate(d_wand, r)
    return d_wand, x, y, r
end

local function watermark(wand, kv)
    fix_params(kv)
    lib.MagickSetImageCompose(wand, lib.DissolveCompositeOp)
    local d_wand, x, y, r = get_draw_wand(kv)
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
        lib.MagickAnnotateImage(wand, d_wand, x, y, r, kv['text'])
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
-- image/watermark,t_15,rotate_30,text_5byg5LiJMjHlubQ45pyINOaXpSAgICAgICAgICA=,fill_1
local kv = gmw.split_param(ngx.var.process_params)

-- 加载
local wand = gmw.read(filename)
-- 处理
watermark(wand, kv)
-- 保存
if (kv['q']) then kv['q'] = tonumber(kv['q']) end
local data = gmw.save(wand, kv['q'])

ngx.print(data)
ngx.exit(ngx.HTTP_OK)