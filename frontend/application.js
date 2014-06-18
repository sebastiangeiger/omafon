window.onload = function() {
  document.body.innerHTML += '<div>Hello from JS</div>'
  var socket = new WebSocket("ws://localhost:8080")
  socket.onopen = function (event) {
    document.body.innerHTML += '<div>Hello from WebSockets</div>'
  };
};
