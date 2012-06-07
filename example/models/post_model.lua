local M = {
    id = nil,
    title = nil,
    body = nil
}

local base = os.getenv("ASTRO_BASE")
local sqlite3 = require("lsqlite3")
local db = assert(sqlite3.open(base .. "db/blog.db"))

function M:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function M:save()
    local stmt

    if self.id then
        stmt = assert(db:prepare("UPDATE posts SET title = :title, body = :body WHERE id = :id"))
        stmt:bind_names({
            title = self.title,
            body = self.body,
            id = self.id
        })
    else
        stmt = assert(db:prepare("INSERT INTO posts (title, body) VALUES (:title, :body)"))
        stmt:bind_names({
            title = self.title,
            body = self.body
        })
    end

    stmt:step()
    stmt:finalize()

    if not self.id then
        self.id = db:last_insert_rowid()
    end

    return self
end

function M:find()
    local results = {}

    for row in db:nrows("SELECT * FROM posts") do
        table.insert(results, row)
    end

    return results
end

function M:find_by_id(id)
    local stmt = assert(db:prepare("SELECT * FROM posts WHERE id = :id"))
    stmt:bind_names({ id = id })

    for row in stmt:nrows() do
        self.id = row.id
        self.title = row.title
        self.body = row.body
    end

    stmt:finalize()

    if self.id then
        return self
    else
        return false
    end
end

return M
