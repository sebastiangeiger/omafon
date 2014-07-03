/** @jsx React.DOM */
var MainUI = React.createClass({
  render: function() {
    return(
      <div className="content">
        <Notifications messages={this.props.uiState.data.notifications}/>
        {this.renderContent()}
      </div>
    );
  },
  renderContent: function() {
    switch (this.props.uiState.state) {
      case "connected":
        return this.renderLogin();
      case "notConnected":
        return this.renderWaitingForConnection();
      case "authenticated":
        return this.renderContactList();
      default:
        console.error("Don't know this UI state: " + this.props.uiState.state);
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
      <LoginWidget onCredentialsSubmitted={uiState.callbacks.onCredentialsSubmitted} loginMessages={uiState.data.loginMessages} />
    );
  },
  renderContactList: function(){
    return (
      <ContactList onlineContacts={uiState.data.onlineContacts}/>
    );
  }
});
