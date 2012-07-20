#!/usr/local/bin/lua

package.path = package.path .. ";../../?/init.lua;../../?.lua"
astro = require("astro")
astro.init()

astro.route({
    ["/"] = { "blog", "index" },
    ["/new"] = { "blog" , "new" },
    ["/logout"] = { "blog", "logout" },
    ["/(%d+)"] = { "blog", "post" }
})
