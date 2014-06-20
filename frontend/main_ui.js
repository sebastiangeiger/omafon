/** @jsx React.DOM */
var MainUI = React.createClass({
  render: function() {
    return (
      <div>
        <LoginWidget loginMessages={this.props.loginMessages} onCredentialsSubmitted={this.props.onCredentialsSubmitted}/>
      </div>
    );
  }
});
