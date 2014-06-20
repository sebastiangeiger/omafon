/**
 * @jsx React.DOM
 */
var socket = new WebSocket("ws://localhost:8080")

window.onload = function() {
  var messages = [];
  renderOrUpdate(messages);


  socket.onopen = function (event) {
    messages.push("WebSocket connected");
    renderOrUpdate(messages);
  };

  socket.onmessage = function(event) {
    console.log(event.data);
    messages.push(event.data);
    renderOrUpdate(messages);
  }

};
function sendCredentials(hash){
  message = {type: "user/sign_in",
             email: hash.email,
             password: hash.password};
  socket.send(JSON.stringify(message));
};

function renderOrUpdate(messages){
  React.renderComponent(
    <LoginWidget loginMessages={messages} onCredentialsSubmitted={sendCredentials}/>,
    document.getElementById('content')
  );
};
