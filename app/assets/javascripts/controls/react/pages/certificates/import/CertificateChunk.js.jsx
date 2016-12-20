/* exported CertificateChunk */
var CertificateChunk = React.createClass({
  propTypes: {
    onRemove: React.PropTypes.func.isRequired,
    id: React.PropTypes.node.isRequired,
    state: React.PropTypes.string.isRequired,
    parsed: React.PropTypes.object
  },
  handleRemove: function() {
    this.props.onRemove(this.props.id);
  },
  render: function() {
    var certificate, private_key;
    if (this.props.certificate !== undefined) {
      var state = this.props.certificate.state;
      if (state === 'fetching') {
        certificate = <span>[Analyzing certificate...]</span>;
      } else if (state === 'errored') {
        certificate = <span className="error">[Failed to analyze. Certificate may not be valid.]</span>;
      } else {
        var cert = this.props.certificate;
        var already_imported;
        if (cert.parsed.id !== null) {
          already_imported = <CertBodyDialogLink model={cert.parsed}>[View existing]</CertBodyDialogLink>;
        }
        certificate = (
          <span>
            <span>Subject: {cert.parsed.subject.CN}</span>
            {already_imported}
          </span>
        );
      }
    }
    if (this.props.private_key !== undefined) {
      var key = this.props.private_key;
      if (key.state === 'fetching') {
        private_key = <span>[Analyzing private key</span>;
      } else {
        private_key = (
          <span>
            <b>Private Key:</b>
            <span>{key.parsed.opts.bit_length} Bits</span>
          </span>
        );
      }
    }
    return (
      <div className="cert-chunk">
        {certificate}
        {private_key}
        <button onClick={this.handleRemove} type="button" className="close" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
    );
  }
});
