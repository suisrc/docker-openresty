local ffi = require "ffi"
local lib = require "gmwand.lib"

-- Wrapper around `MagickGetException` to report errors:
local function magick_error(wand, ctx)
    ctx = ctx or 'error'
    local etype = ffi.new('int[1]')
    local descr = ffi.gc(lib.MagickGetException(wand, etype),lib.MagickRelinquishMemory)
    error(string.format('%s: %s (ExceptionType=%d)', ctx, ffi.string(descr), etype[0]))
end

-- 文件是否存在
local function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then io.close(f) return true else return false end
end

-- 拆分字符串， kv[1] = method
-- resize,w_500,h_500,m_fill/watermark,t_15,rotate_30,text_5byg5LiJMjH
local function split_param(s)
    local kvs = {}
    string.gsub(s,"[^/]+",function(s0)
        local kv={}
        string.gsub(s0,'[^,]+',function(s1)
            if not kv[1] then kv[1] = s1 -- method, ps: resize, watermark
            else local vs= {}            -- params, ps: w_500,h_500,m_fill
                string.gsub(s1,'[^_]+', function(s2) table.insert(vs,s2) end)
                if #vs == 2 then kv[vs[1]] = vs[2] end
            end
        end)
        table.insert(kvs,kv)
    end)
    return kvs
end

-- 读取文件
local function read(filename)
    local wand = ffi.gc(lib.NewMagickWand(), lib.DestroyMagickWand)
    local status = lib.MagickReadImage(wand, filename) -- 读取文件
    -- Error?
    if status == 0 then
        magick_error(wand, 'error loading image')
    end
    return wand
end

-- 保存文件，输出string
local function save(wand, quality)
    quality = quality or 85
    lib.MagickSetCompressionQuality(wand, quality)
    local blen = ffi.new('size_t[1]') -- 写出文件
    local blob = ffi.gc(lib.MagickWriteImageBlob(wand, blen), ffi.C.free)
    local data = ffi.string(blob,tonumber(blen[0]))
    return data
end

-- set or get
local function size(wand,width,height,filter,blur)
    -- Set or get:
    if width or height then
        -- Get filter:c
        local filter = lib[(filter or 'Undefined') .. 'Filter']
        -- Bounding box?
        if not height then
            -- in this case, the image must fit in a widthxwidth box:
            local box = width
            local cwidth,cheight = lib.MagickGetImageWidth(wand), lib.MagickGetImageHeight(wand)
            if cwidth > cheight then
               width = box
               height = box * cheight/cwidth
            else
               height = box
               width = box * cwidth/cheight
            end
        end
        -- Min box?
        if not width then
            -- in this case, the image must cover a heightxheight box:
            local box = height
            local cwidth,cheight = lib.MagickGetImageWidth(wand), lib.MagickGetImageHeight(wand)
            if cwidth < cheight then
               width = box
               height = box * cheight/cwidth
            else
               height = box
               width = box * cwidth/cheight
            end
        end
        blur = blur or 1.0
        -- Set dimensions:
        local status = lib.MagickResizeImage(wand, width, height, filter, blur)
        -- Error?
        if status == 0 then
            magick_error(wand, 'error resizing image')
        end
        return wand
    else
        -- Get dimensions:
        width,height = lib.MagickGetImageWidth(wand), lib.MagickGetImageHeight(wand)
    end
end



return {
    file_exists = file_exists,
    split_param = split_param,
    err = magick_error,
    read = read,
    save = save,
    size = size,
}