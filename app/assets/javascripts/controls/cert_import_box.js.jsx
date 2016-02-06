(function(root) {
  'use strict';
  var CertificateChunk = React.createClass({
    render: function () {
      var body = null;
      if (this.props.hasOwnProperty('fetching')) {
        body = <span>[Analyzing...]</span>;
      }
      if (this.props.hasOwnProperty('parsed')) {
        body = (
          <div>
            <div>Subject: {this.props.parsed.subject.CN}</div>
          </div>
        );
      }
      return (
        <div className="cert-chunk">
          <span>{body}</span>
        </div>
      );
    }
  });

  var CertificateTextBox = React.createClass({
    propTypes: {
      onDetect: React.PropTypes.func.isRequired
    },
    handleType: function(event) {
      var string = event.target.value;
      var bundle = new CertBundle(string);
      for (var i = bundle.certs.length - 1; i >= 0; i--) {
        var cert = bundle.certs[i];
        string = string.substring(0, cert.index) + string.substring(cert.end);
        this.props.onDetect(cert);
      }
      this.setState({text: string});
    },
    render: function() {
      return <textarea onChange={this.handleType} className="cert-input-span" value={this.props.state} />;
    }
  });

  root.CertImportBox = React.createClass({
    getInitialState: function() {
      return {certificates: []};
    },
    handleCertificate: function(body) {
      var certs = this.state.certificates;
      certs.push(body);
      this.props.update(body);
      this.setState({certificates: certs});
    },
    render: function() {
      var elems = [];
      for (var i in this.state.certificates) {
        elems.push(React.createElement(CertificateChunk, this.state.certificates[i]));
      }
      return (
        <span>
          {elems}
          <CertificateTextBox onDetect={this.handleCertificate} />
        </span>
      );
    }
  });
})(this);