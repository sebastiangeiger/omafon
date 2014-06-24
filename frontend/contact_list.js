/** @jsx React.DOM */
var ContactList = React.createClass({
  render: function() {
    var contacts = this.props.onlineContacts;
    var rows = _.map(contacts, function(contact){
      return (<ContactListRow contact={contact}/>);
    });
    return (
      <div id="contactList">
        <h2>Contacts</h2>
        <ul>
        {rows}
        </ul>
      </div>
    );
  }
});

var ContactListRow = React.createClass({
  render: function() {
    return (
      <li class="contact">{this.props.contact}</li>
    );
  }
});
