import CertBundle from 'models/CertBundle';
import PropTypes from 'prop-types';
import React from 'react';

export default class CertificateTextBox extends React.Component {
  constructor(props) {
    super(props);
    this.handlePaste = this.handlePaste.bind(this);
    this.handleType = this.handleType.bind(this);
    this.state = {
      text: ''
    };
  }
  shouldComponentUpdate(nextProps, nextState) {
    return nextState.text !== this.state.text;
  }
  _ingestChunkSet(string, chunks) {
    let consumed = 0;
    for (const cert of chunks) {
      string = string.substring(0, cert.index - consumed) + string.substring(cert.end - consumed);
      consumed += cert.end - cert.index;
    }
    if (chunks.length > 0) {
      this.props.onDetect(chunks);
    }
    return string;
  }
  _processTextBlob(text) {
    const bundle = new CertBundle(text);
    const string = this._ingestChunkSet(text, bundle.all);
    this.setState({ text: string });
  }
  handlePaste(event) {
    // Bypass expensive DOM render by directly accessing the clipboard
    event.preventDefault();
    const text = event.clipboardData.getData('text/plain');
    this._processTextBlob(text);
  }
  handleType(event) {
    this._processTextBlob(event.target.value);
  }
  render() {
    return <textarea onPaste={this.handlePaste} onChange={this.handleType} className="cert-input-span form-control" value={this.state.text} />;
  }
}

CertificateTextBox.propTypes = {
  onDetect: PropTypes.func.isRequired
};
