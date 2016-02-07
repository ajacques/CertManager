(function(root) {
  'use strict';
  var id = 0;
  var CertificateChunk = React.createClass({
    propTypes: {
      onRemove: React.PropTypes.func.isRequired,
      id: React.PropTypes.number.isRequired,
      state: React.PropTypes.string.isRequired,
      parsed: React.PropTypes.object
    },
    shouldComponentUpdate: function(nextProps) {
      return !(this.props.state === nextProps.state && this.props.parsed === nextProps.parsed && this.props.flash === nextProps.flash)
    },
    handleRemove: function() {
      this.props.onRemove(this.props.id);
    },
    render: function() {
      var body = null;
      if (this.props.state === 'fetching') {
        body = <span>[Analyzing...]</span>;
      }
      if (this.props.state === 'loaded') {
        var already_imported;
        if (this.props.parsed.id !== null) {
          already_imported = <CertBodyDialogLink certificate={this.props.parsed} />;
        }
        body = (
          <div>
            <span>Subject: {this.props.parsed.subject.CN}</span>
            {already_imported}
            <button onClick={this.handleRemove} type="button" className="close" aria-label="Close" style={{float: 'inherit'}}>
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
        );
      }
      return (
        <div className="cert-chunk">{body}</div>
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
    },
    handleType: function(event) {
      var string = event.target.value;
      var bundle = new CertBundle(string);
      this._ingestChunkSet(string, bundle.certs);
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
      var dupe = this.state.certificates.find(function(f) { return body.value === f.value});
      if (dupe !== undefined) {
        dupe['flash'] = true;
        return;
      }
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
        text += cert.value;
        elems.push(<CertificateChunk key={cert.key} id={cert.key} parsed={cert.parsed} state={cert.state} onRemove={this.props.onRemove} />);
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