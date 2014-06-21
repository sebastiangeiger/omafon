/**
 * @jsx React.DOM
 */
var socket = new WebSocket("ws://localhost:8080");
var connection = new ApiConnection(socket);

function sendCredentials(hash){
  connection.userSignIn({email: hash.email,
                        password: hash.password});
};

var uiState = {
  state: "notConnected",
  data: {
    notifications: [],
    loginMessages: []
  },
  callbacks: {
    onCredentialsSubmitted: sendCredentials
  }
};

connection.on("open", function(){
  uiState.state = "connected";
  renderOrUpdate(uiState);
});

connection.on("user/sign_in_successful", function(event){
  uiState.data.notifications.push("Signed In");
  uiState.state = "authenticated";
  renderOrUpdate(uiState);
});

window.onload = function() {
  renderOrUpdate(uiState);
};

function renderOrUpdate(uiState){
  React.renderComponent(
    <MainUI uiState={uiState}/>,
    document.getElementById('content')
  );
};
