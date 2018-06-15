import PropTypes from 'prop-types';
import Raven from 'raven-js';
import React from 'react';

/**
 * Root component for all other auto-mounted components to automatically capture exceptions and pass them
 * to Sentry.
 */
export default class RavenErrorContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      error: false
    };
  }
  componentDidCatch(error, errorInfo) {
    Raven.captureException(error, { extra: errorInfo });
  }

  render() {
    return this.props.children;
  }
}

RavenErrorContainer.propTypes = {
  children: PropTypes.element.isRequired
};
