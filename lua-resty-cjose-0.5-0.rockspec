package = "lua-resty-cjose"
version = "0.5"
source = {
   url = "git://github.com/mhamann/lua-resty-cjose",
   tag = "v0.5"
}
description = {
   summary = "Lua cjose bindings for OpenResty.",
   homepage = "https://github.com/mhamann/lua-resty-cjose",
   license = "MIT",
   maintainer = "Matt Hamann <matt@mhamann.com>"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      ["resty.cjose"] = "lib/resty/cjose.lua"
   }
}
