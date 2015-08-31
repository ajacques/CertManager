(function(root) {
  'use strict';
  var CertImportLabel = React.createClass({
    render: function () {
      return (
        <li>{this.props.cert.subject.CN}</li>
      );
    }
  });

  root.CertImportBox = React.createClass({
    flattenDOM: function(elem, array) {
      if (elem.childNodes === null) {
        return;
      }
      for (var i = 0; i < elem.childNodes.length; i++) {
        var node = elem.childNodes[i];
        if (node.nodeType === Node.TEXT_NODE) {
          array.push(node.textContent);
        } else if (node.tagName === "DIV") {
          this.flattenDOM(node, array);
        } else if (node.tagName === "BR") {
          array.push("");
        }
      }
    },
    getInitialState: function() {
      return {certificates: []};
    },
    removeChunk: function(chunk) {
      var text = this.state.text;
      text = text.replace(chunk.value, '');
      this.setState({text: text});
    },
    handleType: function(target) {
      var text = [];
      this.flattenDOM(target, text);
      this.props.update(text.join('\n'));
      var collapsed_html = text.map(function(m) {
        if (m === '') {
          return '<div><br></div>';
        }
        return '<div>' + m + '</div>';
      }).join('');
      this.setState({text: collapsed_html});
    },
    render: function () {
      var certs = this.state.certificates.map(function (cert) {
        return <CertImportLabel cert={cert} />;
      });
      return (
        <div className="cert-input-container">
          <ul>
            {certs}
          </ul>
          <div className="cert-input-container">
            <ContentEditable tagName="span" onChange={this.handleType} html={this.state.text} preventStyling className="cert-input-span" editing={true} />
          </div>
        </div>
      );
    }
  });
})(this);