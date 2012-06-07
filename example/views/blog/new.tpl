<h2>New blog post</h2>
<% if self.error then %>
<p>All fields are required!</p>
<% end %>
<form method="post" action="/new">
<label for="title">Title:</label><br>
<input type="text" name="title" id="title" size="40"><br><br>
<label for="body">Body:</label><br>
<textarea name="body" id="body" rows="8" cols="40"></textarea><br><br>
<input type="submit" name="submit" value="Post">
</form>
