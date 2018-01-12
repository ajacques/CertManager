import PropTypes from 'prop-types';
import SubjectLabel from './SubjectLabel';
import React from 'react';

export default class CertificatePlaceholder extends React.Component {
  renderPrivate() {
    return [
      <div>-----BEGIN PRIVATE KEY-----</div>,
      <div>{this.props.certificate.private_key.fingerprint}</div>,
      <div>-----END PRIVATE KEY-----</div>
    ];
  }
  renderCertificate() {
    const public_key = this.props.certificate.public_key;
    if (!public_key) {
      return [
        <div>{I18n.t('views.services.new.deploy_plan.missing_cert')}</div>
      ];
    }
    return [
      <div>-----BEGIN CERTIFICATE-----</div>,
      <SubjectLabel subject={this.props.certificate.public_key.subject} />,
      <div>-----END CERTIFICATE-----</div>
    ];
  }
  render() {
    let items = ['div', {}];
    if (this.props.includePrivate) {
      items = items.concat(this.renderPrivate());
    }
    items = items.concat(this.renderCertificate());
    return React.createElement.apply(this, items);
  }
}

CertificatePlaceholder.propTypes = {
  certificate: PropTypes.object.isRequired,
  includePrivate: PropTypes.bool
};
