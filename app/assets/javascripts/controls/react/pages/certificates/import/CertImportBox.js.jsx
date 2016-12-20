/* globals CertBundle */
(function(root) {
  'use strict';
  var id = 0;

  var CertificateTextBox = React.createClass({
    propTypes: {
      onDetect: React.PropTypes.func.isRequired
    },
    getInitialState() {
      return {text: ''};
    },
    shouldComponentUpdate: function(nextProps, nextState) {
      return nextState.text !== this.state.text;
    },
    _ingestChunkSet: function(string, chunks) {
      for (var i = chunks.length - 1; i >= 0; i--) {
        var cert = chunks[i];
        string = string.substring(0, cert.index) + string.substring(cert.end);
        this.props.onDetect(cert);
      }
      return string;
    },
    _processTextBlob: function(text) {
      var bundle = new CertBundle(text);
      var string = this._ingestChunkSet(text, bundle.all);
      this.setState({text: string});
    },
    handlePaste: function(event) {
      // Bypass expensive DOM render by directly accessing the clipboard
      event.preventDefault();
      var text = event.clipboardData.getData('text/plain');
      this._processTextBlob(text);
    },
    handleType: function(event) {
      this._processTextBlob(event.target.value);
    },
    render: function() {
      return <textarea onPaste={this.handlePaste} onChange={this.handleType} className="cert-input-span" value={this.state.text} />;
    }
  });

  root.CertImportBox = React.createClass({
    propTypes: {
      certificates: React.PropTypes.array.isRequired,
      update: React.PropTypes.func.isRequired,
      onRemove: React.PropTypes.func.isRequired
    },
    getInitialState: function() {
      return {certificates: []};
    },
    handleCertificate: function(body) {
      body.key = id++;
      this.props.update(body);
    },
    dragOver: function(event) {
      event.dataTransfer.effectAllowed = "copyMove";
      event.dataTransfer.dropEffect = "move";
      event.preventDefault();
      return false;
    },
    handleDrop: function(event) {
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
    },
    render: function() {
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
  });
})(this);
