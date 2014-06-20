/** @jsx React.DOM */
var LoginWidget = React.createClass({
  getInitialState: function() {
    return {loginMessages: ["Loginmessages here!"]};
  },
  handleSubmit: function(){
    var email = this.refs.email.getDOMNode().value.trim();
    var password = this.refs.password.getDOMNode().value.trim();
    this.props.onCredentialsSubmitted({email: email, password: password});
    return false;
  },
  render: function() {
    return (
      <div id="loginWidget">
        <form id="login" onSubmit={this.handleSubmit}>

          <label for="email">E-mail:</label>
          <input type="text" name="email" id="email" ref="email"/>

          <label for="password">Password:</label>
          <input type="password" name="password" ref="password"/>

          <input type="submit" value="Sign in"/>
        </form>
        <div id="loginMessages">{this.props.loginMessages}</div>
      </div>
    );
  }
});