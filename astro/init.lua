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
    get = {},
    post = {},
    cookie = require("astro.cookie"),
    helper = require("astro.helper"),
    session = require("astro.session"),
    tincan = require("astro.tincan"),
    view = require("astro.view")
}

local request = os.getenv("REQUEST_URI") or "/"

function M.init()
    M.base = os.getenv("DOCUMENT_ROOT") .. "/../"
    local method = string.upper(os.getenv("REQUEST_METHOD"))
    local get = os.getenv("QUERY_STRING") or ""
    local post = ""
    local cookie = os.getenv("HTTP_COOKIE") or ""

    if method == "POST" then
        post = io.read(tonumber(os.getenv("CONTENT_LENGTH")))
    end

    for k, v in string.gmatch(get .. "&", "(.-)%=(.-)%&") do
        M.get[k] = M.helper.url_decode(v)
    end

    for k, v in string.gmatch(post .. "&", "(.-)%=(.-)%&") do
        M.post[k] = M.helper.url_decode(v)
    end

    for k, v in string.gmatch(cookie .. "; ", "(.-)%=(.-)%; ") do
        M.cookie.cookies[k] = M.helper.url_decode(v)
    end

    request = string.gsub(request, "%?.*$", "")

    if request ~= "/" then
        if string.sub(request, -1) == "/" then
            request = string.sub(request, 1, -2)
        end
    end
end

function M.route(routes)
    routes = routes or {}

    for k, v in pairs(routes) do
        -- global scope so controllers can access request params
        matches = { string.match(request, "^" .. k .. "$") }

        if #matches > 0 then
            package.path = package.path .. ";" .. M.base .. "models/?.lua"
            dofile(M.base .. "controllers/" .. v[1] .. '.lua')
            local str = v[2] .. "("

            if matches[1] ~= k then
                str = str .. "table.unpack(matches)"
            end

            str = str .. ")"

            assert(load(str))()
            return
        end
    end

    io.write("Status: 404 Not Found\r\n")
    M.view.render_file("error/404.tpl")
end

return M
