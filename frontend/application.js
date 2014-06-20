/**
 * @jsx React.DOM
 */
var socket = new WebSocket("ws://localhost:8080")

function sendCredentials(hash){
  message = {type: "user/sign_in",
             email: hash.email,
             password: hash.password};
  socket.send(JSON.stringify(message));
};

var uiState = {
  state: "notConnected",
  data: {
    loginMessages: []
  },
  callbacks: {
    onCredentialsSubmitted: sendCredentials
  }
};


window.onload = function() {
  var messages = [];
  renderOrUpdate(uiState);

  socket.onopen = function (event) {
    uiState.state = "connected";
    renderOrUpdate(uiState);
  };

  socket.onmessage = function(event) {
    console.log(event.data);
    uiState.data.loginMessages.push(event.data);
    renderOrUpdate(uiState);
  }

};

function renderOrUpdate(uiState){
  React.renderComponent(
    <MainUI uiState={uiState}/>,
    document.getElementById('content')
  );
};
