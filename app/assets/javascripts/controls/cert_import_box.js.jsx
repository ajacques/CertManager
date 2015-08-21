var CertImportBox = React.createClass({
  handleType: function(event) {
  },
  render: function() {
    return (
      <div>
        <textarea onChange={this.handleType} className="certificate" />
      </div>
    );
  }
});