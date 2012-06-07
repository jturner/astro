<% for i, post in ipairs(self.posts) do %>
<h2><a href="/<%= post.id %>"><%= post.title %></a></h2>
<p><%= post.body %></p>
<% end %>
<a href="/new">Add a new post</a>
