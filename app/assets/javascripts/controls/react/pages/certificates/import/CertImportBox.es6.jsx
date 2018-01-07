/* globals CertBundle */
class CertImportBox extends React.Component {
  constructor(props) {
    super(props);
    this.dragOver = this.dragOver.bind(this);
    this.handleDrop = this.handleDrop.bind(this);
    this.onRemove = this.onRemove.bind(this);
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
      var reader = new FileReader();
      var self = this;
      reader.onload = function(text) {
        // Validate format
        var content = text.target.result;
        var bundle = new CertBundle(content);
        for (var i = 0; i < bundle.certs.length; i++) {
          self.handleCertificate(bundle.certs[i]);
        }
      };
      for (var i = 0; i < event.dataTransfer.files.length; i++) {
        reader.readAsText(event.dataTransfer.files[i]);
        event.preventDefault();
      }
    }
  }
  render() {
    var elems = [];
    var text = '';
    for (var i in this.props.certificates) {
      var cert = this.props.certificates[i];
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
