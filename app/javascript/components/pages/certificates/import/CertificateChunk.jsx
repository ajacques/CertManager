/* exported CertificateChunk */
import PropTypes from 'prop-types';
import React from 'react';

export default class CertificateChunk extends React.Component {
  handleRemove() {
    this.props.onRemove(this.props.id);
  }
  renderKnownCertificate() {
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
  }
  renderCertificate() {
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
  }
  renderPrivateKey() {
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
  }
  render() {
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
}

CertificateChunk.propTypes = {
  certificate: PropTypes.object.isRequired,
  onRemove: PropTypes.func.isRequired,
  id: PropTypes.node.isRequired,
  state: PropTypes.string.isRequired,
  parsed: PropTypes.object
};
