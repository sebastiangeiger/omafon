function ApiConnection(socket){
  //ApiConnection is used as a communication channel to the websockets server
  //It has two main functions:
  //1. Listening to socket events and messages and offering them to subscibers
  //   in a slightly nicer and more consistent format
  var _self = this;
  var _listeners = {};
  this.on = function(event_name, callback){
    _listeners[event_name] = [callback]
  };
  this._trigger = function(event){
    callbacks = _listeners[event.type] || [];
    _.each(callbacks, function(callback){
      callback(event);
    });
  };
  socket.onopen = function (event) {
    _self._trigger(event);
  };
  socket.onmessage = function (event) {
    console.log("Client received: " + event.data);
    var message = JSON.parse(event.data);
    _self._trigger(message);
  };

  //2. Offering all API methods to the rest of the frontend
  this.userSignIn = function(hash){
    hash.type = "user/sign_in";
    this._send(hash);
  };
  this._send = function(hash){
    socket.send(JSON.stringify(hash));
  };

}
