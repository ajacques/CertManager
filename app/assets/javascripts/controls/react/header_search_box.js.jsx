(function() {
  'use strict';
  var outerContext = this;
  this.HeaderSearchBox = React.createClass({
    propTypes: {
      query: React.PropTypes.string
    },
    getInitialState: function() {
      var state = {
        suggestions: [],
        float_open: false,
        mouse_over: false,
        typedValue: this.props.query || ''
      };
      if (outerContext.debounce) {
        state.debouncer = outerContext.debounce(this.requestSuggestions, 200, false, 3);
      }
      return state;
    },
    requestSuggestions: function() {
      var query = this.state.typedValue;
      if (query === this.state.query) {
        return;
      }
      this.setState({query: query});
      if (query === '') {
        this.setState({suggestions: []});
        return;
      }
      var req = Ajax.get(Routes.search_results_path(), {
        acceptType: 'application/json',
        data: {
          query: query
        }
      });
      req.then(this._handleSuggestions);
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
    handleScroll: function(event) {
      if (event.keyCode === 38) {
        this.setState({selected_index: Math.max(this.state.selected_index - 1, -1)});
        event.preventDefault();
      } else if (event.keyCode === 40) {
        this.setState({selected_index: Math.min(this.state.selected_index + 1, this.state.suggestions.length - 1)});
        event.preventDefault();
      } else if (event.keyCode === 13 && this.state.selected_index >= 0) {
        var selectedCert = this.state.suggestions[this.state.selected_index];
        window.location.href = selectedCert.url;
        event.preventDefault();
      }
    },
    handleMouseOverSuggestions: function() {
      this.setState({mouse_over: true});
    },
    handleMouseOutSuggestions: function() {
      this.setState({mouse_over: false});
    },
    typeThunk: function(event) {
      this.setState({typedValue: event.target.value});
      this.state.debouncer();
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
        panelStyle.display = 'none';
      }
      return (
        <div className="search-suggest-container">
          <input autoComplete="off" className="form-control" name="query"
                 onBlur={this.handleBlur} onChange={this.typeThunk} onFocus={this.handleFocus} onKeyDown={this.handleScroll}
                 placeholder="Search" tabIndex="1" type="search" value={this.state.typedValue} />
          <div className="float"
               onMouseOut={this.handleMouseOutSuggestions} onMouseOver={this.handleMouseOverSuggestions}
               style={panelStyle}>
            {suggests}
          </div>
        </div>
      );
    }
  });
}).call(this);
