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
    id = nil,
    sessions = {}
}

function M.start_session()
    local chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local session = astro.cookie.get_cookie("ASTROSESSID")

    if session then
        astro.tincan.load(astro.base .. "tmp/sess_" .. session)

        if astro.tincan.exists("session") then
            M.sessions = astro.tincan.get("session")
        end
    else
        session = ""

        local urandom = assert(io.open("/dev/urandom"))
        local bytes = { string.byte(urandom:read(16), 1, -1) }
        math.randomseed(os.time() + tonumber(table.concat(bytes)))
        urandom:close()

        for i = 1, 26 do
            local char = math.random(string.len(chars))
            session = session .. string.sub(chars, char, char)
        end

        astro.cookie.set_cookie("ASTROSESSID", session)
        astro.tincan.load(astro.base .. "tmp/sess_" .. session)
    end

    M.id = session
end

function M.save_session()
    if M.id then
        astro.tincan.set("session", M.sessions)
        astro.tincan.save(astro.base .. "tmp/sess_" .. M.id)
    end
end

function M.destroy_session()
    if M.id then
        astro.cookie.delete_cookie("ASTROSESSID")
        astro.tincan.destroy(astro.base .. "tmp/sess_" .. M.id)

        M.id = nil
        M.sessions = {}
    end
end

return M
