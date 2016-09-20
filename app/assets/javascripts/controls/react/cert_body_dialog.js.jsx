(function() {
  'use strict';
  var modalPoint;
  (window.on_pageload || []).push(function() {
    modalPoint = document.createElement('div');
    document.body.appendChild(modalPoint);
  });
  this.CertBodyDialog = React.createClass({
    propTypes: {
      model: React.PropTypes.object.isRequired,
      onClose: React.PropTypes.func.isRequired
    },
    getDefaultProps: function() {
      return {formats: ['pem', 'text', 'json']};
    },
    getInitialState: function() {
      return {format: 'pem', include_chain: false};
    },
    handleChangeFormat: function(format, event) {
      event.preventDefault();
      this.changeFormat(format);
    },
    triggerBodyUpdate: function(format, include_chain) {
      if (include_chain) {
        this.props.model.getChain(format).then(this.changeBody);
      } else {
        this.props.model.get_format(format).then(this.changeBody);
      }
    },
    changeFormat: function(format) {
      this.setState({format: format});
      this.triggerBodyUpdate(format, this.state.include_chain);
    },
    changeBody: function(body) {
      this.setState({text: body});
    },
    handleIncludeChain: function(event) {
      this.setState({include_chain: event.target.checked});
      this.triggerBodyUpdate(this.state.format, event.target.checked);
    },
    render: function() {
      var formatElems = [];
      var self = this;
      this.props.formats.forEach(function(format) {
        var link = <a href={Routes.certificate_path({id: self.props.model.id}, {format: format})} onClick={self.handleChangeFormat.bind(null, format)}>{format}</a>;
        var isActive = format === self.state.format;
        formatElems.push(<li className={classNames({active: isActive})} key={format}>{link}</li>);
      });
      return (
        <div className="modal modal-visible center-block">
          <div className="modal-dialog">
            <div className="modal-content">
              <div className="modal-header">
                <button className="close close-button" onClick={this.props.onClose}>&times;</button>
                <h4 className="modal-title">Certificate Details</h4>
              </div>
              <ul className="nav nav-tabs nav-justified">{formatElems}</ul>
              <pre className="certificate modal-body">{this.state.text}</pre>
              <div>
                <div className="modal-footer">
                  <label>
                    <input type="checkbox" onChange={this.handleIncludeChain} checked={this.state.include_chain} />
                    Include chain
                  </label>
                  <button className="close-button btn btn-default" onClick={this.props.close}>Close</button>
                </div>
              </div>
            </div>
          </div>
        </div>
      );
    }
  });
  var self = this;
  this.CertBodyDialogLink = React.createClass({
    propTypes: {
      model: React.PropTypes.object.isRequired
    },
    close: function() {
      ReactDOM.unmountComponentAtNode(modalPoint)
    },
    _getModel: function() {
      var model = this.props.model;
      if (model.hasOwnProperty('get_format')) {
        return model;
      }
      if (self[model.type] === undefined) {
        return model;
      }
      return self[model.type].find(model.id);
    },
    openWindow: function(event) {
      event.preventDefault();
      var elem = ReactDOM.render(<CertBodyDialog model={this._getModel()} onClose={this.close} />, modalPoint);
      elem.changeFormat(elem.state.format);
      return false;
    },
    render: function() {
      return (
        <a onClick={this.openWindow} href={Routes.public_key_path({id: this.props.model.id})}>{this.props.children}</a>
      );
    }
  })
}).call(this);
