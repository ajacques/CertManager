(function(root) {
  'use strict';
  var CertificateChunk = React.createClass({
    render: function () {
      var body = null;
      if (this.props.hasOwnProperty('fetching')) {
        body = <span>[Analyzing...]</span>;
      }
      if (this.props.hasOwnProperty('parsed')) {
        body = (
          <div>
            <div>Subject: {this.props.parsed.subject.CN}</div>
          </div>
        );
      }
      return (
        <div className="cert-chunk">
          <div className="cert-boundary">-----BEGIN {this.props.type}-----</div>
          <div className="cert-boundary">{this.props.values.length} lines hidden</div>
          {body}
          <div className="cert-boundary">-----END {this.props.type}-----</div>
        </div>
      );
    }
  });

  var UnrecognizedTyping = React.createClass({
    render: function() {
      if (this.props.text === '') {
        return <div><br/></div>;
      } else {
        return (
          <div>{this.props.text}</div>
        );
      }
    }
  });

  root.CertImportBox = React.createClass({
    flattenDOM: function(elem, array) {
      if (elem.childNodes === undefined) {
        return;
      }
      for (var i = 0; i < elem.childNodes.length; i++) {
        var node = elem.childNodes[i];
        if (node.nodeType === Node.TEXT_NODE) {
          array.push(node.textContent);
        } else if (node.tagName === "DIV" || node.tagName === "SPAN") {
          this.flattenDOM(node, array);
        } else if (node.tagName === "BR") {
          array.push("");
        }
      }
    },
    getInitialState: function() {
      return {certificates: [], text: [], bundle: []};
    },
    handleType: function(event) {
      var text = event.target.value.split('\n');
      this.props.update.call(this, text);
      this.setState({text: text});
    },
    render: function() {
      var elems = [];
      var value = this.state.text;
      this.state.bundle.forEach(function(cert) {
        if (cert.type === 'CERTIFICATE') {
          elems.push(React.createElement(CertificateChunk, cert))
        }
      });
      return (<span>
          <div>{elems}</div>
          <textarea onChange={this.handleType} className="cert-input-span" />
        </span>
      );
    }
  });
})(this);