local Post = require("post_model")

function index()
    local post = Post:new()
    astro.view.posts = post.find()
    astro.view.render_file("blog/index.tpl")
end

function new()
    astro.session.start_session()

    if astro.session.sessions.logged_in then
        if (astro.post.title and #astro.post.title > 0) and
            (astro.post.body and #astro.post.body > 0) then
            local post = Post:new({
                title = astro.post.title,
                body = astro.post.body
            })

            local ret = post:save()
            astro.helper.redirect("/" .. ret.id)
        elseif astro.post.submit then
            astro.view.error = true
        end

        astro.view.render_file("blog/new.tpl")
    else
        if (astro.post.user and #astro.post.user > 0) and
            (astro.post.pass and #astro.post.pass > 0) then
            if astro.post.user == "demo" and astro.post.pass == "demo" then
                astro.session.sessions.logged_in = true
                astro.helper.redirect("/new")
            else
                astro.view.error = "invalid"
            end
        elseif astro.post.submit then
            astro.view.error = "fields"
        end

        astro.view.render_file("blog/login.tpl")
    end
end

function logout()
    astro.session.start_session()
    astro.session.sessions.logged_in = nil
    astro.helper.redirect("/")
end

function post(id)
    local post = Post:new()
    astro.view.post = post:find_by_id(id)

    if astro.view.post then
        astro.view.render_file("blog/post.tpl")
    else
        io.write("status: 404 Not Found\n")
        astro.view.render_file("error/404.tpl")
    end
end
