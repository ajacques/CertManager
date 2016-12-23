/* exported CertificateChunk */
var CertificateChunk = React.createClass({
  propTypes: {
    certificate: React.PropTypes.object.isRequired,
    onRemove: React.PropTypes.func.isRequired,
    id: React.PropTypes.node.isRequired,
    state: React.PropTypes.string.isRequired,
    parsed: React.PropTypes.object
  },
  handleRemove: function() {
    this.props.onRemove(this.props.id);
  },
  renderKnownCertificate: function() {
    var cert = this.props.certificate;
    var already_imported;
    if (cert.parsed.id !== null) {
      already_imported = <CertBodyDialogLink model={cert.parsed}>[View existing]</CertBodyDialogLink>;
    }
    return (
      <span>
        <span>Subject: {cert.parsed.subject.CN}</span>
        {already_imported}
      </span>
    );
  },
  renderCertificate: function() {
    if (this.props.certificate === undefined) {
      return null;
    }
    var state = this.props.certificate.state;
    if (state === 'fetching') {
      return <span>[Analyzing certificate...]</span>;
    } else if (state === 'errored') {
      return <span className="error">[Failed to analyze. Certificate may not be valid.]</span>;
    } else {
      return this.renderKnownCertificate();
    }
  },
  renderPrivateKey: function() {
    if (this.props.private_key === undefined) {
      return null;
    }
    var key = this.props.private_key;
    if (key.state === 'fetching') {
      return <span>[Analyzing private key</span>;
    } else {
      return (
        <span>
          <b>Private Key:</b>
          <span>{key.parsed.opts.bit_length} Bits</span>
        </span>
      );
    }
  },
  render: function() {
    return (
      <div className="cert-chunk">
        {this.renderCertificate()}
        {this.renderPrivateKey()}
        <button onClick={this.handleRemove} type="button" className="close" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
    );
  }
});
