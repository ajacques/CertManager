class AgentNewForm extends React.Component {
  constructor(props) {
    super(props);
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
  }
  static propTypes() {
    return {
      imageName: React.PropTypes.string.isRequired
    };
  }
  refreshData() {
    if (this.state.inflightRequest !== null) {
      this.state.inflightRequest.abort();
    }
    var reconciledTags = {};
    for (var i = 0; i < this.state.tags.length; i++) {
      var tagRecord = this.state.tags[i];
      reconciledTags[tagRecord.key] = tagRecord.value;
    }
    var req = $.ajax(Routes.generate_token_agent_index_path(), {
      type: 'POST',
      dataType: 'text',
      contentType: 'json',
      data: JSON.stringify({
        tags: reconciledTags
      })
    }).success(this.handleToken);
    this.setState({loading: true, inflightRequest: req});
  }
  componentWillUpdate(newProps, newState) {
    if (this.state.tags !== newState.tags) {
      this.state.refreshData();
    }
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
    var index = event.currentTarget.dataset.index;
    var valueBox = this.refs['tag-row-' + index];
    if (event.keyCode === 187) { // Equals sign
      event.preventDefault();
      valueBox.focus();
    }
  }
  upsertTagAt(index, props) {
    var newTags = this.state.tags.slice();
    if (this.state.tags.length < index) {
      newTags.push($.extend({}, {
        key: null,
        value: null
      }, props));
    } else {
      var oldTag = this.state.tags[index];
      newTags[index] = $.extend({}, oldTag, props);
    }
    if (!newTags[index].key && !newTags[index].value) {
      newTags.slice(index);
    }
    this.setState({tags: newTags, dirty: true});
  }
  handleTagKeyChange(event) {
    var index = event.currentTarget.dataset.index;
    this.upsertTagAt(index, {key: event.currentTarget.value});
  }
  handleTagValueChange(event) {
    var index = event.currentTarget.dataset.index;
    this.upsertTagAt(index, {value: event.currentTarget.value});
  }
  registrationUrl() {
    return window.location.host + Routes.agent_register_path(this.state.auth_token);
  }
  launchCommand() {
    if (!(this.state.dirty && this.state.auth_token)) {
      return '';
    }
    return "sudo docker run -d -v /var/run/docker.sock:/var/run/docker.sock " + this.props.imageName + " register " + this.registrationUrl();
  }
  renderTagRow(index) {
    return (
      <li>
        <input onKeyDown={this.handlePossibleEquals} onChange={this.handleTagKeyChange} data-index={index} type="text" />
        <input onChange={this.handleTagValueChange} data-index={index} type="text" />
      </li>
    );
  }
  render() {
    return (
      <div>
        <li>
          <h4>Tag</h4>
          <ul className="list-unstyled">
            {this.renderTagRow(0)}
          </ul>
        </li>
        <li>
          <h4>Launch</h4>
          <p>Execute the following command on the remote host</p>
          <textarea className="agent-new-form--command-box" onClick={this.handleTokenClick} readOnly="readonly"
                    type="text" value={this.launchCommand()} />
        </li>
      </div>
    );
  }
}
