import PropTypes from 'prop-types';
import React from 'react';

export default class CertBodyDialog extends React.Component {
  constructor(props) {
    super(props);
    this.changeBody = this.changeBody.bind(this);
    this.state = {
      format: 'pem'
    };
  }
  handleChangeFormat(format, event) {
    event.preventDefault();
    this.changeFormat(format);
  }
  triggerBodyUpdate(format, include_chain) {
    if (include_chain) {
      this.props.model.getChain(format).then(this.changeBody);
    } else {
      this.props.model.get_format(format).then(this.changeBody);
    }
  }
  changeFormat(format) {
    this.setState({ format: format });
    this.triggerBodyUpdate(format, this.state.include_chain);
  }
  changeBody(body) {
    let data = body;
    if (typeof body === "object") {
      data = JSON.stringify(body);
    }
    this.setState({text: data});
  }
  handleIncludeChain(event) {
    this.setState({include_chain: event.target.checked});
    this.triggerBodyUpdate(this.state.format, event.target.checked);
  }
  render() {
    const formatElems = [];
    CertBodyDialog.formats.forEach(format => {
      const link = <a href={Routes.certificate_path({id: this.props.model.id}, {format: format})} onClick={this.handleChangeFormat.bind(null, format)}>{format}</a>;
      const isActive = format === self.state.format;
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
                <button className="close-button btn btn-default" onClick={this.props.onClose}>Close</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

CertBodyDialog.formats = ['pem', 'text', 'json'];
CertBodyDialog.propTypes = {
  model: PropTypes.object.isRequired,
  onClose: PropTypes.func.isRequired
};
