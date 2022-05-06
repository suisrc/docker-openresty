-- Magick
local ffi = require "ffi"
local lib = require "gmwand.lib"
local fun = require "gmwand.fun"

return {
    file_exists = fun.file_exists,
    split_param = fun.split_param,
    lib = lib,
    err = fun.err,
    read = fun.read,
    save = fun.save,
    size = fun.size,
}