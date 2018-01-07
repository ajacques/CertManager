/* globals CertBundle */
class CertificateTextBox extends React.Component {
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
    for (var i = chunks.length - 1; i >= 0; i--) {
      var cert = chunks[i];
      string = string.substring(0, cert.index) + string.substring(cert.end);
      this.props.onDetect(cert);
    }
    return string;
  }
  _processTextBlob(text) {
    var bundle = new CertBundle(text);
    var string = this._ingestChunkSet(text, bundle.all);
    this.setState({ text: string });
  }
  handlePaste(event) {
    // Bypass expensive DOM render by directly accessing the clipboard
    event.preventDefault();
    var text = event.clipboardData.getData('text/plain');
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