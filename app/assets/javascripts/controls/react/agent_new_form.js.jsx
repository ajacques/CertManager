(function(root) {
  'use strict';
  root.AgentNewForm = React.createClass({
    propTypes: {
      imageName: React.PropTypes.string.isRequired
    },
    getInitialState: function() {
      return {tags: {}, loading: true};
    },
    componentWillUpdate: function(newProps, newState) {
      if (this.state.tags !== newState.tags) {
        this.setState({loading: true});
        $.ajax(Routes.generate_token_agent_index_path(), {
          type: 'POST',
          dataType: 'text',
          contentType: 'json',
          data: JSON.stringify({
            tags: this.state.tags
          })
        }).success(this.handleToken);
      }
    },
    handleToken: function(response) {
      this.setState({auth_token: response, loading: false});
    },
    updateTag: function(event) {
      var newTags = $.extend({}, this.state.tags, {foo: event.currentTarget.value});
      this.setState({tags: newTags});
    },
    handleTokenClick: function(event) {
      event.preventDefault();
      // Automatically highlight the entire text
      event.currentTarget.select(0, event.currentTarget.value.length);
    },
    registrationUrl: function() {
      return window.location.host + Routes.agent_register_path(this.state.auth_token);
    },
    launchCommand: function() {
      if (this.state.loading && !this.state.auth_token) {
        return '';
      }
      return "sudo docker run -d -v /var/run/docker.sock:/var/run/docker.sock " + this.props.imageName + " register " + this.registrationUrl();
    },
    render: function() {
      return (
        <div>
          <li>
            <h4>Tag</h4>
            <input type="text" onChange={this.updateTag} />
          </li>
          <li>
            <h4>Launch</h4>
            <p>Execute the following command on the remote host</p>
            <input onClick={this.handleTokenClick} readOnly="readonly" type="text" value={this.launchCommand()} />
          </li>
        </div>
      );
    }
  });
})(this);