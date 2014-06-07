window.onload = function() {
  var socket = new WebSocket("ws://localhost:8888/ws");

  socket.onopen = function(){
    console.log("%cOpened connection ", "color: blue");
  };

  socket.onmessage = function (message) {
    console.log("%cReceived: " + message.data, "color: blue");
  };

};

