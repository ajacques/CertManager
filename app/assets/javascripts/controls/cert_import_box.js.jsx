(function(root) {
  'use strict';
  var CertificateChunk = React.createClass({
    render: function () {
      var body = null;
      if (this.props.hasOwnProperty('fetching')) {
        body = <span>[Analyzing...]</span>;
      }
      if (this.props.hasOwnProperty('parsed')) {
        body = <div>Subject: {this.props.parsed.subject.CN}</div>;
      }
      return (
        <div>
          <div>-----BEGIN {this.props.type}-----</div>
          <div>{this.props.values.length} lines hidden</div>
          {body}
          <div>-----END {this.props.type}-----</div>
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
    removeChunk: function(chunk) {
      var text = this.state.text;
      //text = text.replace(chunk.value, '');
      //this.setState({text: text});
    },
    handleType: function(target) {
      var text = [];
      this.flattenDOM(target, text);
      this.props.update.call(this, text);
      this.setState({text: text});
    },
    render: function () {
      var elems = [];
      this.state.bundle.forEach(function(cert) {
        if (cert.type === 'CERTIFICATE') {
          elems.push(React.createElement(CertificateChunk, cert));
        } else {
          elems.push(React.createElement(UnrecognizedTyping, {text: cert.values}));
        }
      });
      var content_html = React.renderToStaticMarkup(React.createElement('span', {}, elems));
      return (
        <ContentEditable tagName="span" onChange={this.handleType} html={content_html} preventStyling className="cert-input-span" editing={true} />
      );
    }
  });
})(this);