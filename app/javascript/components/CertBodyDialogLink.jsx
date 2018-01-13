import Certificate from 'models/Certificate';
import PublicKey from 'models/PublicKey';
import CertBodyDialog from './CertBodyDialog';
import PropTypes from 'prop-types';
import React from 'react';
import ReactDOM from 'react-dom';

export default class CertBodyDialogLink extends React.Component {
  constructor(props) {
    super(props);
    this.openWindow = this.openWindow.bind(this);
    this.close = this.close.bind(this);
  }
  close() {
    ReactDOM.unmountComponentAtNode(CertBodyDialogLink.modalPoint);
  }
  _getModel() {
    const model = this.props.model;
    if (model.hasOwnProperty('get_format')) {
      return model;
    }
    if (model.type === "Certificate") {
      return Certificate.find(model.id);
    } else if (model.type === "PublicKey") {
      return PublicKey.find(model.id);
    }
    return this[model.type].find(model.id);
  }
  openWindow(event) {
    event.preventDefault();
    const elem = ReactDOM.render(<CertBodyDialog model={this._getModel()} onClose={this.close} />, CertBodyDialogLink.modalPoint);
    elem.changeFormat(elem.state.format);
    return false;
  }
  render() {
    return (
      <a onClick={this.openWindow} href={Routes.public_key_path({id: this.props.model.id})}>{this.props.children}</a>
    );
  }
}

if (typeof document !== "undefined") {
  CertBodyDialogLink.modalPoint = document.createElement('div');
  document.body.appendChild(CertBodyDialogLink.modalPoint);
}

CertBodyDialogLink.propTypes = {
  model: PropTypes.object.isRequired,
  children: PropTypes.string.isRequired
};
