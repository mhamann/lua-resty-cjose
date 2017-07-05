local _M = {}
local ffi = require('ffi')
ffi.cdef [[


]]


local cjose, err = pcall(ffi, load('cjose'))
if err then
  print('\n ERROR: libcjose is not installed correctly. lua-resty-cjose will not work.')
  assert(false)
end
local _M


