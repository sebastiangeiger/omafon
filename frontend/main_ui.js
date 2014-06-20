/** @jsx React.DOM */
var MainUI = React.createClass({
  render: function() {
    switch (this.props.uiState.state) {
      case "connected":
        return this.renderLogin();
      case "notConnected":
        return this.renderWaitingForConnection();
      default:
        console.error("Don't know this UI state: " + this.props.state);
    }
  },
  renderWaitingForConnection: function(){
    return (
      <div>Waiting for Connection</div>
    );
  },
  renderLogin: function(){
    var uiState = this.props.uiState;
    return (
      <div>
        <LoginWidget loginMessages={uiState.data.loginMessages}
                     onCredentialsSubmitted={uiState.callbacks.onCredentialsSubmitted}/>
      </div>
    );
  }
});
