--[[
Copyright (c) 2012 James Turner <james@calminferno.net>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]

local M = {}

local buffer = {}

function write(...)
    local args, n = {...}, select("#", ...)

    for i = 1, n do
        args[i] = astro.helper.html_special_chars(tostring(args[i]))
    end

    table.insert(buffer, table.concat(args, " "))
end

local env = {
    bit32 = bit32,
    io = { write = write },
    ipairs = ipairs,
    math = math,
    next = next,
    pairs = pairs,
    pcall = pcall,
    print = write,
    os = {
        clock = os.clock,
        date = os.date,
        difftime = os.difftime,
        execute = os.execute,
        getenv = os.getenv,
        time = os.time,
    },
    select = select,
    self = M,
    string = string,
    table = table,
    tonumber = tonumber,
    tostring = tostring,
    type = type
}

function M.render_string(str)
    prepare()
    io.write("content-type: text/html\n\n")
    io.write(str)
    os.exit()
end

function M.render_file(file)
    local base = os.getenv("ASTRO_BASE")

    local wrapper = assert(io.open(base .. "views/global/wrapper.tpl"))
    wrapper = wrapper:read("*a")

    local view = assert(io.open(base .. "views/" .. file))
    view = view:read("*a")

    wrapper = string.gsub(wrapper, "{{maincontent}}\n", function ()
        return view
    end)

    wrapper = "html = [==[" .. wrapper
    wrapper = string.gsub(wrapper, "<%%=%s*(.-)%s*%%>", "<%% io.write(%1) %%>")
    wrapper = string.gsub(wrapper, "<%%%s*(io.write)", "$token]==]\n%1")
    wrapper = string.gsub(wrapper, "<%%%s*(print)", "$token]==]\n%1")
    wrapper = string.gsub(wrapper, "<%%%s*", "]==]\n")
    wrapper = string.gsub(wrapper, "%s*%%>", "\nhtml = html .. [==[")
    wrapper = wrapper .. "]==]\nreturn html"

    wrapper = assert(load(wrapper, "", "t", env))()

    wrapper = string.gsub(wrapper, "(%$token)", function (m)
        return table.remove(buffer, 1)
    end)

    prepare()
    io.write("content-type: text/html\n\n")
    io.write(wrapper)
    os.exit()
end

function M.render_json(str)
    prepare()
    io.write("content-type: application/json\n\n")
    io.write(str)
    os.exit()
end

function prepare()
    astro.session.save_session()
    io.write(astro.cookie.set_cookies())
end

return M
