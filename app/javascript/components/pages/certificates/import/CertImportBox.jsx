import CertBundle from 'models/CertBundle';
import CertificateChunk from './CertificateChunk';
import CertificateTextBox from './CertificateTextBox';
import PropTypes from 'prop-types';
import React from 'react';

const idSym = Symbol();

export default class CertImportBox extends React.Component {
  constructor(props) {
    super(props);
    this.dragOver = this.dragOver.bind(this);
    this.handleDrop = this.handleDrop.bind(this);
    this.handleCertificate = this.handleCertificate.bind(this);
  }
  handleCertificate(body) {
    for (const elem of body) {
      elem.key = CertImportBox[idSym]++;
    }
    this.props.update(body);
  }
  dragOver(event) {
    event.dataTransfer.effectAllowed = "copyMove";
    event.dataTransfer.dropEffect = "move";
    event.preventDefault();
    return false;
  }
  handleDrop(event) {
    if (event.dataTransfer.files.length >= 1) {
      const reader = new FileReader();
      reader.onload = text => {
        // Validate format
        const content = text.target.result;
        const bundle = new CertBundle(content);
        for (let i = 0; i < bundle.certs.length; i++) {
          this.handleCertificate(bundle.certs[i]);
        }
      };
      for (let i = 0; i < event.dataTransfer.files.length; i++) {
        reader.readAsText(event.dataTransfer.files[i]);
        event.preventDefault();
      }
    }
  }
  render() {
    const elems = [];
    for (const cert of this.props.certificates) {
      if (cert.certificate !== undefined && cert.cert_id === null) {
        elems.push(<input key={`${cert.key}_cert`} type="hidden" name="certificate[key][]" value={cert.certificate.value} />);
      }
      if (cert.private_key !== undefined) {
        elems.push(<input key={`${cert.key}_priv`} type="hidden" name="certificate[key][]" value={cert.private_key.value} />);
      }
      elems.push(<CertificateChunk key={cert.key} id={cert.key} certificate={cert.certificate}
        private_key={cert.private_key} state={cert.state} onRemove={this.props.onRemove} />);
    }
    return (
      <span onDragOver={this.dragOver} onDrop={this.handleDrop}>
        {elems}
        <CertificateTextBox onDetect={this.handleCertificate} />
      </span>
    );
  }
}
CertImportBox[idSym] = 0;

CertImportBox.propTypes = {
  certificates: PropTypes.array.isRequired,
  update: PropTypes.func.isRequired,
  onRemove: PropTypes.func.isRequired
};
