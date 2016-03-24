(function(root) {
  'use strict';
  root.SubjectAltNameList = React.createClass({
    getInitialState: function() {
      return {names: ''};
    },
    handleChange: function(event) {
      this.setState({names: event.target.value});
    },
    _inputBox: function(text) {
      var name = undefined;
      if (text !== '') {
        name = "certificate[csr_attributes][sans][]";
      }
      return (
        <input name={name} onChange={this.handleChange} type="text" className="san-textbox form-control" />
      );
    },
    render: function() {
      return this._inputBox(this.state.names);
    }
  });
})(this);