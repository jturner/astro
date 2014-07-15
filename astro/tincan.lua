--[[
Copyright (c) 2011, 2012 James Turner <james@calminferno.net>

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
    store = {}
}

local function serialize(o)
    local t = {}

    if type(o) == "boolean" or type(o) == "number" then
        table.insert(t, tostring(o))
    elseif type(o) == "string" then
        table.insert(t, string.format("%q", o))
    elseif type(o) == "table" then
        table.insert(t, "{")

        for k, v in pairs(o) do
            table.insert(t, "[")
            table.insert(t, serialize(k))
            table.insert(t, "] = ")
            table.insert(t, serialize(v))
            table.insert(t, ",")
        end

        table.insert(t, "}")
    else
        error("cannot serialize a " .. type(o))
    end

    return table.concat(t)
end

function M.set(key, value)
    M.store[key] = value
    return value
end

function M.get(key)
    return M.store[key]
end

function M.delete(key)
    M.store[key] = nil
    return nil
end

function M.exists(key)
    if M.store[key] then
        return true
    else
        return false
    end
end

function M.incr(key)
    local value = M.store[key]

    if type(value) == "number" then
        M.store[key] = value + 1
        return value + 1
    else
        error("cannot increment a non-number")
    end
end

function M.decr(key)
    local value = M.store[key]

    if type(value) == "number" then
        M.store[key] = value - 1
        return value - 1
    else
        error("cannot decrement a non-number")
    end
end

function M.load(file)
    file = file or "tincan.db"
    local func, err = loadfile(file)

    if func then
        M.store = func()
    elseif not string.find(err, "No such file", 1, true) then
        error("cannot parse file " .. file)
    end
end

function M.save(file)
    file = file or "tincan.db"
    file = assert(io.open(file, "w"))
    file:write("return " .. serialize(M.store))
    file:close()
end

function M.destroy(file)
    file = file or "tincan.db"
    os.remove(file)
end

return M
