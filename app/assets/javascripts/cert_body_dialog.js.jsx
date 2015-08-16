var CertBodyDialog = React.createClass({
  getInitialState: function() {
    return {format: 'pem'};
  },
  handleChangeFormat: function(format) {
    this.setState({format: format});
    this.props.modal.get_format(format).then(this.changeBody);
  },
  changeBody: function(body) {
    this.setState({text: body});
  },
  handleIncludeChain: function(event) {
    this.setState({include_chain: true});
  },
  render: function() {
    var formats = ['pem', 'text', 'yaml', 'json'];
    var formatElems = [];
    var self = this;
    formats.forEach(function(format) {
      var link = <a onClick={self.handleChangeFormat.bind(null, format)} format={format}>{format}</a>;
      if (format === self.state.format) {
        formatElems.push(<li className="active">{link}</li>);
      } else {
        formatElems.push(<li>{link}</li>);
      }
    });
    return (
      <div className="modal modal-visible center-block">
        <div className="modal-dialog">
          <div className="modal-content">
            <div className="modal-header">
              <button className="close close-button" onClick={this.handleClose}>&times;</button>
              <h4 className="modal-title">Certificate Details</h4>
            </div>
            <ul className="nav nav-tabs nav-justified">{formatElems}</ul>
            <pre className="certificate modal-body">{this.state.text}</pre>
            <div className="modal-footer">
              <label>
                <input type="checkbox" onChange={this.handleIncludeChain} checked={this.state.includeChain} />
                Include chain
              </label>
              <button className="close-button btn btn-default" onClick={this.props.close}>Close</button>
            </div>
          </div>
        </div>
      </div>
    );
  }
});