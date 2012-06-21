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

local M = {
    cookies = {}
}

local cookiejar = {}

function M.set_cookie(name, value, options)
    local cookie = {
        value  = value,
        options = options or {}
    }

    M.cookies[name] = value
    cookiejar[name] = cookie
end

function M.get_cookie(name)
    return M.cookies[name]
end

function M.delete_cookie(name)
    M.cookies[name] = nil
    cookiejar[name] = {
        value = "",
        options = {
            expire = os.time() - 3600
        }
    }
end

function M.set_cookies()
    local headers = {}

    for k, v in pairs(cookiejar) do
        local header = "Set-Cookie: " .. k .. "=" .. astro.helper.url_encode(v.value)

        if v.options.expire then
            header = header .. "; Expires=" .. os.date("!%a, %d-%b-%Y %H:%M:%S GMT", v.options.expire)
        end

        if v.options.path then
            header = header .. "; Path=" .. v.options.path
        end

        if v.options.domain then
            header = header .. "; Domain=" .. v.options.domain
        end

        if v.options.secure then
            header = header .. "; Secure"
        end

        table.insert(headers, header)
    end

    if #headers > 0 then
        table.insert(headers, "")
        return table.concat(headers, "\r\n")
    else
        return ""
    end
end

return M
