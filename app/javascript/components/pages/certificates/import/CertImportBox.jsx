import CertBundle from 'models/CertBundle';
import CertificateChunk from './CertificateChunk';
import CertificateTextBox from './CertificateTextBox';
import PropTypes from 'prop-types';
import React from 'react';

export default class CertImportBox extends React.Component {
  constructor(props) {
    super(props);
    this.dragOver = this.dragOver.bind(this);
    this.handleDrop = this.handleDrop.bind(this);
    this.handleCertificate = this.handleCertificate.bind(this);
    this.state = {
      certificates: []
    };
  }
  handleCertificate(body) {
    body.key = CertImportBox.id++;
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
    let text = '';
    for (let i in this.props.certificates) {
      const cert = this.props.certificates[i];
      if (cert.certificate !== undefined) {
        text += cert.certificate.value;
      }
      if (cert.private_key !== undefined) {
        text += cert.private_key.value;
      }
      elems.push(<CertificateChunk key={cert.key} id={cert.key} certificate={cert.certificate}
        private_key={cert.private_key} state={cert.state} onRemove={this.props.onRemove} />);
    }
    return (
      <span onDragOver={this.dragOver} onDrop={this.handleDrop}>
        <input type="hidden" name="certificate[key]" value={text} />
        {elems}
        <CertificateTextBox onDetect={this.handleCertificate} />
      </span>
    );
  }
}
CertImportBox.id = 0;

CertImportBox.propTypes = {
  certificates: PropTypes.array.isRequired,
  update: PropTypes.func.isRequired,
  onRemove: PropTypes.func.isRequired
};
