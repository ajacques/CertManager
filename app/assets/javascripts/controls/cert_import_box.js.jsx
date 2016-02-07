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
      return !(this.props.state === nextProps.state && this.props.parsed === nextProps.parsed)
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
        body = (
          <div>
            <span>Subject: {this.props.parsed.subject.CN}</span>
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
    handleType: function(event) {
      var string = event.target.value;
      var bundle = new CertBundle(string);
      for (var i = bundle.certs.length - 1; i >= 0; i--) {
        var cert = bundle.certs[i];
        cert['key'] = id++;
        string = string.substring(0, cert.index) + string.substring(cert.end);
        this.props.onDetect(cert);
      }
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
      this.props.update(body);
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
        <span>
          <input type="hidden" name="certificate[key]" value={text} />
          {elems}
          <CertificateTextBox onDetect={this.handleCertificate} />
        </span>
      );
    }
  });
})(this);