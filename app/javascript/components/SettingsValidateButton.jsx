import React from 'react';
import PropTypes from 'prop-types';

export default class SettingsValidateButton extends React.Component {
  constructor(props) {
    super(props);
    this.clickButton = this.clickButton.bind(this);
    this.handleResponse = this.handleResponse.bind(this);
    this.handleFailure = this.handleFailure.bind(this);
    this.state = {
      state: 'nothing'
    };
  }
  componentDidMount() {
    this.functor = Routes[`validate_${this.props.target}_settings_path`];
  }

  // Event Handlers
  clickButton(event) {
    event.preventDefault();

    if (this.state.state !== 'nothing') {
      return;
    }

    this.setState({state: 'loading'});
    Ajax.post(this.functor(), { acceptType: 'application/json' }).then(this.handleResponse, this.handleFailure);
  }
  handleResponse() {
    this.setState({state: 'success'});
  }
  handleFailure(response) {
    this.setState({state: 'failed', error: response.message});
  }

  render() {
    const classes = ['loadable-button', 'btn'];
    const props = {
      onClick: this.clickButton
    };
    let innerContent;
    if (this.state.state === 'loading') {
      innerContent = 'Testing';
      classes.push('disabled');
    } else if (this.state.state === 'success') {
      innerContent = 'Success';
      classes.push('btn-success');
    } else if (this.state.state === 'failed') {
      innerContent = 'Failed';
      props.title = this.state.error;
      classes.push('btn-danger');
    } else {
      innerContent = 'Test Settings';
    }

    props.className = classNames(classes);
    return React.createElement('button', props, innerContent);
  }
}

SettingsValidateButton.propTypes = {
  target: PropTypes.string.isRequired
};
