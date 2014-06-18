/**
 * @jsx React.DOM
 */

window.onload = function() {
  var messages = [];
  renderOrUpdate(messages);

  var socket = new WebSocket("ws://localhost:8080")

  socket.onopen = function (event) {
    messages.push("WebSocket connected");
    renderOrUpdate(messages);
  };

};

function renderOrUpdate(messages){
  React.renderComponent(
    <LoginWidget loginMessages={messages}/>,
    document.getElementById('content')
  );
}
