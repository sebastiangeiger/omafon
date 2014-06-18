/** @jsx React.DOM */
var LoginWidget = React.createClass({
  getInitialState: function() {
    return {loginMessages: ["Loginmessages here!"]};
  },
  render: function() {
    return (
      <div id="loginWidget">
        <form id="login">
          <label for="email">E-mail:</label><input type="text" name="email" id="email"/>
          <label for="password">Password:</label><input type="password" name="password"/>
          <input type="submit" value="Sign in"/>
        </form>
        <div id="loginMessages">{this.props.loginMessages}</div>
      </div>
    );
  }
});
