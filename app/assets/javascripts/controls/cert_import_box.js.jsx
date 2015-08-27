(function(root) {
  'use strict';
  var CertImportLabel = React.createClass({
    render: function () {
      return (
        <li>{this.props.cert.subject.CN}</li>
      );
    }
  });
  var ComplexTextBox = React.createClass({
    flattenDOM: function(elem, array) {
      for (var i = 0; i < elem.childNodes.length; i++) {
        var node = elem.childNodes[i];
        if (node.nodeType === Node.TEXT_NODE) {
          array.push("<div>" + node.textContent + "</div>");
        } else if (node.tagName === "DIV") {
          this.flattenDOM(node, array);
        } else if (node.tagName === "BR") {
          //array.push("<br>");
        }
      }
    },
    shouldComponentUpdate(nextProps) {
      return nextProps.html !== React.findDOMNode(this).innerHTML;
    },
    componentDidUpdate() {
      if ( this.props.html !== React.findDOMNode(this).innerHTML ) {
        React.findDOMNode(this).innerHTML = this.props.html;
      }
    },
    handleType: function(event) {
      var html = React.findDOMNode(this).innerHTML;
      var text = [];
      this.flattenDOM(event.target, text);
      text = text.join('\n');
      this.props.onChange(html);
    },
    render: function() {
      return (
        <span className="cert-input-span" onInput={this.handleType} contentEditable="true" dangerouslySetInnerHTML={{__html: this.props.html}} />
      )
    }
  });

  root.CertImportBox = React.createClass({
    getInitialState: function() {
      return {certificates: []};
    },
    removeChunk: function(chunk) {
      var text = this.state.text;
      text = text.replace(chunk.value, '');
      this.setState({text: text});
    },
    handleType: function(event) {
      this.setState({text: event});
    },
    render: function () {
      var certs = this.state.certificates.map(function (cert) {
        return <CertImportLabel cert={cert} />;
      });
      var editing = true;
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