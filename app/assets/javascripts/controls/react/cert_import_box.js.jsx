(function(root) {
  'use strict';
  var id = 0;
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
        if (this.props.certificate.state === 'fetching') {
          certificate = <span>[Analyzing certificate...]</span>
        } else {
          var cert = this.props.certificate;
          var already_imported;
          if (cert.parsed.id !== null) {
            already_imported = <CertBodyDialogLink certificate={cert.parsed}>[View existing]</CertBodyDialogLink>;
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
          <button onClick={this.handleRemove} type="button" className="close" aria-label="Close"
                  style={{float: 'inherit'}}>
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
      );
    }
  });

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
    handleType: function(event) {
      var string = event.target.value;
      var bundle = new CertBundle(string);
      string = this._ingestChunkSet(string, bundle.all);
      this.setState({text: string});
    },
    render: function() {
      return <textarea onChange={this.handleType} className="cert-input-span" value={this.state.text} />;
    }
  });

  root.CertImportBox = React.createClass({
    getInitialState: function() {
      return {certificates: []};
    },
    handleCertificate: function(body) {
      body['key'] = id++;
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
      for (var i in this.state.certificates) {
        var cert = this.state.certificates[i];
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