/* exported CertificateImportContainer */
import Certificate from 'models/Certificate';
import CertImportBox from './CertImportBox';
import PrivateKey from 'models/PrivateKey';
import React from 'react';

export default class CertificateImportContainer extends React.Component {
  constructor(props) {
    super(props);
    this.appendRecords = this.appendRecords.bind(this);
    this.handleAnalyze = this.handleAnalyze.bind(this);
    this.handlePrivateKeyAnalyze = this.handlePrivateKeyAnalyze.bind(this);
    this.handleRemove = this.handleRemove.bind(this);
    this.state = {
      certificates: []
    };
  }

  handleAnalyze(root, match) {
    return {
      success: result => {
        if (result.opts.id !== undefined) {
          root.cert_id = result.opts.id;
        }
        match.parsed = result;
        match.state = 'loaded';
        this.forceUpdate();
      },
      fail: result => {
        match.state = 'errored';
        match.error = result.responseText;
        this.forceUpdate();
      }
    };
  }
  findCertById(id) {
    const certificates = this.state.certificates;
    for (let i = 0; i < certificates.length; i++) {
      if (certificates[i].cert_id === id) {
        return certificates[i];
      }
    }
    return null;
  }
  findCertByFingerprint(fingerprint) {
    const certificates = this.state.certificates;
    for (let i = 0; i < certificates.length; i++) {
      if (certificates[i].fingerprint === fingerprint) {
        return certificates[i];
      }
    }
    return null;
  }
  handleRemove(key) {
    const newCerts = this.state.certificates.slice();
    const index = newCerts.findIndex(f => f.key === key);
    newCerts.splice(index, 1);
    this.setState({certificates: newCerts});
  }
  handlePrivateKeyAnalyze(root) {
    let certificates = this.state.certificates;
    let private_key = root.private_key;
    return result => {
      if (result.opts.public_keys.length >= 1) {
        let cert = this.findCertById(result.opts.public_keys[0].id);
        if (cert === null) {
          cert = this.findCertByFingerprint(result.opts.fingerprint);
        }
        if (cert !== null) {
          // Race condition. use filter
          certificates = certificates.filter(function(f) {
            return f !== root;
          });
          private_key = cert.private_key = {
            value: private_key.value
          };
        } else {
          root.cert_id = result.opts.public_keys[0].id;
        }
      }
      private_key.parsed = result;
      private_key.state = 'loaded';
      this.forceUpdate();
    };
  }
  ingestRecord(chunk) {
    const item = {
      state: 'fetching',
      value: chunk.value
    };
    const cert = {
      state: 'fetching',
      key: chunk.key,
      certificate: undefined,
      private_key: undefined
    };
    if (chunk.type === 'CERTIFICATE') {
      cert.certificate = item;
      const functors = this.handleAnalyze(cert, item);
      Certificate.analyze(chunk.value).then(functors.success, functors.fail);
    } else if (chunk.type === 'RSA PRIVATE KEY') {
      cert.private_key = item;
      PrivateKey.analyze(chunk.value).then(this.handlePrivateKeyAnalyze(cert));
    }
    return cert;
  }
  appendRecords(records) {
    const newCerts = this.state.certificates.slice();

    for (const record of records) {
      newCerts.push(this.ingestRecord(record));
    }
    this.setState({certificates: newCerts});
  }

  render() {
    return (
      <CertImportBox certificates={this.state.certificates} update={this.appendRecords} onRemove={this.handleRemove} />
    );
  }
}
