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

local entities = {
    ['"'] = "&quot;",
    ["'"] = "&#39;",
    ["<"] = "&lt;",
    [">"] = "&gt;",
    ["&"] = "&amp;"
}

function M.url_decode(str)
    str = string.gsub(str, "+", " ")
    str = string.gsub(str, "%%(%x%x)", function (h)
        return string.char(tonumber(h, 16))
    end)
    str = string.gsub(str, "\r\n", "\n")

    return str
end

function M.url_encode(str)
    str = string.gsub(str, "\n", "\r\n")
    str = string.gsub(str, "([^%w ])", function (c)
        return string.format("%%%02X", string.byte(c))
    end)
    str = string.gsub(str, " ", "+")

    return str
end

function M.html_special_chars(str)
    str = string.gsub(str, "[\"'<>&]", function (c)
        return entities[c]
    end)

    return str
end

function M.redirect(str)
    io.write("Status: 302 Found\r\n")

    if string.match(str, "http(s?)://") then
        io.write("Location: " .. str .. "\r\n")
    else
        local protocol = os.getenv("HTTPS") == "on" and "https://" or "http://"
        io.write("Location: " .. protocol .. os.getenv("HTTP_HOST") .. str .. "\r\n")
    end

    astro.view.render_string("302 Found")
end

return M
