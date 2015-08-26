(function(root) {
  'use strict';
  var CertImportLabel = React.createClass({
    render: function () {
      return (
        <li>{this.props.cert.subject.CN}</li>
      );
    }
  });

  root.CertImportBox = React.createClass({
    handleType: function (event) {
      this.setState({text: event.target.value});
      this.props.update(event.target.value);
    },
    getInitialState: function () {
      return {certificates: []};
    },
    removeChunk: function(chunk) {
      var text = this.state.text;
      text = text.replace(chunk.value, '')
      this.setState({text: text});
    },
    render: function () {
      var certs = this.state.certificates.map(function (cert) {
        return <CertImportLabel cert={cert}/>;
      });
      return (
        <div>
          <ul>
            {certs}
          </ul>
          <textarea onChange={this.handleType} className="certificate" value={this.state.text} />
        </div>
      );
    }
  });
})(this);