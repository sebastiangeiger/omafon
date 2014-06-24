/** @jsx React.DOM */
var NotificationRow = React.createClass({
  render: function() {
    return (
      <li>{this.props.message}</li>
    );
  }
});

var Notifications = React.createClass({
  render: function() {
    var messages = this.props.messages;
    var rows = _.map(messages, function(message){
      return (<NotificationRow message={message}/>);
    });
    return (
      <ul id="notifications">
        {rows}
      </ul>
    );
  }
});
