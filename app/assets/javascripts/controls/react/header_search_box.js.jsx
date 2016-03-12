(function() {
  this.HeaderSearchBox = React.createClass({
    requestSuggestions: function(event) {
      var query = event.target.value;
      if (query === this.state.query) {
        return;
      }
      this.setState({query: query});
      if (query === '') {
        this.setState({suggestions: []});
        return;
      }
      $.ajax({
        url: Routes.search_results_path(),
        method: 'GET',
        data: {
          query: query
        }
      }).success(this._handleSuggestions);
    },
    _handleSuggestions: function(data) {
      this.setState({suggestions: data, float_open: true, selected_index: -1});
    },
    handleBlur: function(event) {
      if (this.state.mouse_over) {
        return;
      }
      this.setState({float_open: false});
    },
    handleFocus: function() {
      this.setState({float_open: true});
    },
    getInitialState: function() {
      var state = {suggestions: [], float_open: false, mouse_over: false};
      if (window.hasOwnProperty('debounce')) {
        state['debouncer'] = debounce(this.requestSuggestions, 200, false, 3);
      }
      return state;
    },
    handleScroll: function(event) {
      if (event.keyCode === 38) {
        this.setState({selected_index: Math.max(this.state.selected_index - 1, -1)});
        event.preventDefault();
      } else if (event.keyCode === 40) {
        this.setState({selected_index: Math.min(this.state.selected_index + 1, this.state.suggestions.length - 1)});
        event.preventDefault();
      } else if (event.keyCode === 13 && this.state.selected_index >= 0) {
        var selected_cert = this.state.suggestions[this.state.selected_index];
        window.location.href = selected_cert.url;
        event.preventDefault();
      }
    },
    handleMouseOverSuggestions: function() {
      this.setState({mouse_over: true});
    },
    handleMouseOutSuggestions: function() {
      this.setState({mouse_over: false});
    },
    render: function() {
      var suggests = [];
      for (var i = 0; i < this.state.suggestions.length; i++) {
        var style = classNames('search-option', {'search-highlighted-option': this.state.selected_index === i});
        suggests.push(<div key={i} className={style}>
          <a href={this.state.suggestions[i].url}>{this.state.suggestions[i].subject}</a>
        </div>);
      }
      var panelStyle = {};
      if (!this.state.float_open && this.state.suggestions.length > 0) {
        panelStyle['display'] = 'none';
      }
      return (
        <div className="search-suggest-container">
          <input tabIndex="1" onKeyDown={this.handleScroll} onBlur={this.handleBlur} onFocus={this.handleFocus} onChange={this.state.debouncer} type="search" name="query" className="form-control" placeholder="Search" autoComplete="off" />
          <div onMouseOver={this.handleMouseOverSuggestions} onMouseOut={this.handleMouseOutSuggestions} className="float" style={panelStyle}>{suggests}</div>
        </div>
      );
    }
  });
}).call(this);
