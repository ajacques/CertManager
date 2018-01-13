import Ajax from 'utilities/Ajax';
import PropTypes from 'prop-types';
import React from 'react';

export default class AgentNewForm extends React.Component {
  constructor(props) {
    super(props);
    this.refreshData = this.refreshData.bind(this);
    this.state = {
      tags: [],
      loading: true,
      dirty: false,
      inflightRequest: null,
      refreshData: debounce(this.refreshData, 1000, false)
    };
    this.handlePossibleEquals = this.handlePossibleEquals.bind(this);
    this.handleTagValueChange = this.handleTagValueChange.bind(this);
    this.handleTagKeyChange = this.handleTagKeyChange.bind(this);
    this.handleToken = this.handleToken.bind(this);
  }
  refreshData() {
    if (this.state.inflightRequest !== null) {
      this.state.inflightRequest.abort();
    }
    const reconciledTags = {};
    for (let i = 0; i < this.state.tags.length; i++) {
      const tagRecord = this.state.tags[i];
      reconciledTags[tagRecord.key] = tagRecord.value;
    }
    const req = Ajax.post(Routes.generate_token_agent_index_path(), {
      contentType: 'application/json',
      acceptType: 'text/plain',
      data: {
        tags: reconciledTags
      }
    });
    req.then(this.handleToken);
    this.setState({loading: true, inflightRequest: req});
  }
  componentWillUpdate(newProps, newState) {
    if (this.state.tags !== newState.tags) {
      this.refreshData();
    }
  }
  componentDidMount() {
    this.refreshData();
  }
  handleToken(response) {
    this.setState({auth_token: response, loading: false});
  }
  static handleTokenClick(event) {
    event.preventDefault();
    // Automatically highlight the entire text
    event.currentTarget.select(0, event.currentTarget.value.length);
  }
  handlePossibleEquals(event) {
    const index = event.currentTarget.dataset.index;
    if (event.keyCode === 187) { // Equals sign
      event.preventDefault();
      const valueBox = this.refs['tag-row-' + index];
      valueBox.focus();
    }
  }
  upsertTagAt(index, props) {
    const newTags = this.state.tags.slice();
    if (this.state.tags.length < index) {
      newTags.push(Object.assign({
        key: null,
        value: null
      }, props));
    } else {
      const oldTag = this.state.tags[index];
      newTags[index] = Object.assign({}, oldTag, props);
    }
    if (!newTags[index].key && !newTags[index].value) {
      newTags.slice(index);
    }
    this.setState({tags: newTags, dirty: true});
  }
  handleTagKeyChange(event) {
    const index = event.currentTarget.dataset.index;
    this.upsertTagAt(index, {key: event.currentTarget.value});
  }
  handleTagValueChange(event) {
    const index = event.currentTarget.dataset.index;
    this.upsertTagAt(index, {value: event.currentTarget.value});
  }
  registrationUrl() {
    return `${window.location.protocol}//${window.location.host}${Routes.agent_register_path(this.state.auth_token)}`;
  }
  launchCommand() {
    if (!this.state.auth_token) {
      return '';
    }
    return `sudo docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ${this.props.imageName} register ${this.registrationUrl()}`;
  }
  renderTagRow(index) {
    return (
      <li>
        <input onKeyDown={this.handlePossibleEquals} onChange={this.handleTagKeyChange} data-index={index} type="text" />
        <input ref={"tag-row-" + index} onChange={this.handleTagValueChange} data-index={index} type="text" />
      </li>
    );
  }
  tagListElement() {
    return (
      <li>
        <h4>Tag</h4>
        <ul className="list-unstyled">
          {this.renderTagRow(0)}
        </ul>
      </li>
    );
  }
  render() {
    return (
      <div>
        {this.tagListElement()}
        <li>
          <h4>Launch</h4>
          <p>Execute the following command on the remote host</p>
          <textarea className="agent-new-form--command-box" onClick={this.handleTokenClick} readOnly="readonly"
                    value={this.launchCommand()} />
        </li>
      </div>
    );
  }
}

AgentNewForm.propTypes = {
  imageName: PropTypes.string.isRequired
};
