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
    registrationUrl: function() {
      return window.location.host + Routes.agent_register_path(this.state.auth_token);
    },
    renderLaunchCommand: function() {
      if (this.state.loading) {
      } else {
        return <code>sudo docker run -d -v /var/run/docker.sock:/var/run/docker.sock {this.props.imageName} register {this.registrationUrl()}</code>;
      }
    },
    render: function() {
      return (
        <div>
          <li>
            <h4>Tag</h4>
            <input type="text" onChange={this.updateTag} />
          </li>
          <li>
            {this.renderLaunchCommand()}
          </li>
        </div>
      );
    }
  });
})(this);