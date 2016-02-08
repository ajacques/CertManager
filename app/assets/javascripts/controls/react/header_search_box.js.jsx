(function() {
  this.HeaderSearchBox = React.createClass({
    requestSuggestions: function() {

    },
    getInitialState: function() {
      return {debounce: debounce(this.requestSuggestions, 500, false)};
    },
    render: function() {
      return (
        <input onChange={this.state.debounce} type="search" name="query" className="form-control" placeholder="Search" />
      );
    }
  });
}).call(this);