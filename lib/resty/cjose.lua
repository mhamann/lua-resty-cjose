local cjson = require 'cjson'
local _M = {}
local ffi = require('ffi')
ffi.cdef [[
  typedef enum _cjose_errcode {CJOSE_ERR_NONE, CJOSE_ERR_INVALID_ARG, CJOSE_ERR_INVALID_STATE, CJOSE_ERR_NO_MEMORY, CJOSE_ERR_CRYPTO} cjose_errcode;
  typedef int size_t;
  typedef struct _cjose_err {cjose_errcode code; char* message; char* function; char* file; long line;} cjose_err;  
  typedef struct _cjose_jws_int cjose_jws_t;
  typedef struct _cjose_jwk_int cjose_jwk_t;
  cjose_jwk_t* cjose_jwk_import(char* json, size_t len, cjose_err* err);
  cjose_jws_t* cjose_jws_import(char* payload, size_t len, cjose_err* err);
  bool cjose_jws_verify(cjose_jws_t* data, cjose_jwk_t* key, cjose_err* err);
  bool cjose_jws_get_plaintext(cjose_jws_t* jws, uint8_t** text, size_t* len, cjose_err* err); 
  void *malloc(size_t size);
  void free(void *ptr);
]]

local cjose = ffi.load('cjose')


function _M.getJWSInfo(document)
  local c_strdoc = ffi.new('char[?]', #document)
  ffi.copy(c_strdoc, document, #document)
  local err = ffi.new('cjose_err')
  local c_doc = cjose.cjose_jws_import(c_strdoc, #document, err)
  if err.code > 0 then
    print ('error loading jws: ' .. ffi.string(err.message))
    return nil
  end
  local size = ffi.gc(ffi.C.malloc(ffi.sizeof('size_t')), ffi.C.free)
  local text = ffi.gc(ffi.C.malloc(ffi.sizeof('char*')), ffi.C.free) -- create a char** on the heap so we can actually get a result
  local result = cjose.cjose_jws_get_plaintext(c_doc, text, size, err) 
  if err.code > 0 then 
    print ('error getting plain text for jws: ' .. ffi.string(err.message))
    return nil
  end
  return ffi.string(ffi.cast("char**", text)[0])
end

function _M.validateJWS(document, key)
  local c_strkey = ffi.new('char[?]', #key)
  ffi.copy(c_strkey, key)
  local err = ffi.new('cjose_err') 
  local c_key = cjose.cjose_jwk_import(c_strkey, #key, err)
  if err.code > 0 then
    print('error loading key: ' .. ffi.string(err.message))
    return nil
  end
  local c_strsig = ffi.new('char[?]', #document)
  ffi.copy(c_strsig, document)
  local c_sig = cjose.cjose_jws_import(c_strsig, #document, err)
  if err.code > 0 then 
    print('error loading document: ' .. ffi.string(err.message))
    return nil
  end
  local result = cjose.cjose_jws_verify(c_sig, c_key, err) 
  
  return result
end

return _M

