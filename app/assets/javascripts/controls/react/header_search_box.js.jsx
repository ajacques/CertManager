(function() {
  this.HeaderSearchBox = React.createClass({
    render: function() {
      return (
        <input type="search" name="query" className="form-control" placeholder="Search" />
      );
    }
  });
}).call(this);