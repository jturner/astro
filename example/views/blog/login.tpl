<h2>Login</h2>
<% if self.error == "fields" then %>
<p>All fields are required!</p>
<% elseif self.error == "invalid" then %>
<p>Invalid credentials!</p>
<% end %>
<form method="post" action="/new">
<label for="user">Username:</label><br>
<input type="text" name="user" id="user" size="40"><br><br>
<label for="pass">Password:</label><br>
<input type="pass" name="pass" id="pass" size="40"><br><br>
<input type="submit" name="submit" value="Log In">
</form>
