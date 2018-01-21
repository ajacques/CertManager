import Certificate from 'models/Certificate';
import PublicKey from 'models/PublicKey';
import CertBodyDialog from './CertBodyDialog';
import PropTypes from 'prop-types';
import React from 'react';
import ReactDOM from 'react-dom';

const modalPoint = typeof document !== "undefined" && document.body.appendChild(document.createElement('div'));

export default class CertBodyDialogLink extends React.Component {
  constructor(props) {
    super(props);
    this.close = this.close.bind(this);
    this.openWindow = this.openWindow.bind(this);
    this.state = {
      open: false
    };
  }
  close() {
    this.setState({ open: false });
  }
  _getModel() {
    const model = this.props.model;
    if (model.hasOwnProperty('getFormat')) {
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
    this.setState({ open: true });
    return false;
  }
  render() {
    return (
      <React.Fragment>
        {this.state.open && ReactDOM.createPortal(<CertBodyDialog model={this._getModel()} onClose={this.close} />, modalPoint)}
        <a onClick={this.openWindow} href={Routes.public_key_path({id: this.props.model.id})}>{this.props.children}</a>
      </React.Fragment>
    );
  }
}



CertBodyDialogLink.propTypes = {
  model: PropTypes.object.isRequired,
  children: PropTypes.string.isRequired
};
