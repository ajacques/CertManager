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
    handleType: function (event) {
      this.props.update(event.target.value);
    },
    getInitialState: function () {
      return {certificates: []};
    },
    render: function () {
      var certs = this.state.certificates.map(function (cert) {
        return <CertImportLabel cert={cert}/>;
      });
      return (
        <div>
          <ul>
            {certs}
          </ul>
          <textarea onChange={this.handleType} className="certificate"/>
        </div>
      );
    }
  });
})(this);