import classNames from 'classnames';
import React from 'react';
import PropTypes from 'prop-types';

export default class HeaderSearchBox extends React.Component {
  constructor(props) {
    super(props);
    this.requestSuggestions = this.requestSuggestions.bind(this);
    this._handleSuggestions = this._handleSuggestions.bind(this);
    this.handleFocus = this.handleFocus.bind(this);
    this.handleBlur = this.handleBlur.bind(this);
    this.handleScroll = this.handleScroll.bind(this);
    this.typeThunk = this.typeThunk.bind(this);
    this.state = {
      suggestions: [],
      float_open: false,
      mouse_over: false,
      typedValue: this.props.query || ''
    };
  }
  componentDidMount() {
    if (window && window.debounce) {
      this.debouncer = window.debounce(this.requestSuggestions, 200, false, 3);
    }
  }
  requestSuggestions() {
    const query = this.state.typedValue;
    if (query === this.state.query) {
      return;
    }
    this.setState({query: query});
    if (query === '') {
      this.setState({suggestions: []});
      return;
    }
    const req = Ajax.get(Routes.search_results_path(), {
      acceptType: 'application/json',
      data: {
        query: query
      }
    });
    req.then(this._handleSuggestions);
  }
  _handleSuggestions(data) {
    this.setState({suggestions: data, float_open: true, selected_index: -1});
  }
  handleBlur() {
    if (this.state.mouse_over) {
      return;
    }
    this.setState({float_open: false});
  }
  handleFocus() {
    this.setState({float_open: true});
  }
  handleScroll(event) {
    if (event.keyCode === 38) {
      this.setState({selected_index: Math.max(this.state.selected_index - 1, -1)});
      event.preventDefault();
    } else if (event.keyCode === 40) {
      this.setState({selected_index: Math.min(this.state.selected_index + 1, this.state.suggestions.length - 1)});
      event.preventDefault();
    } else if (event.keyCode === 13 && this.state.selected_index >= 0) {
      const selectedCert = this.state.suggestions[this.state.selected_index];
      window.location.href = selectedCert.url;
      event.preventDefault();
    }
  }
  handleMouseOverSuggestions() {
    this.setState({mouse_over: true});
  }
  handleMouseOutSuggestions() {
    this.setState({mouse_over: false});
  }
  typeThunk(event) {
    this.setState({typedValue: event.target.value});
    this.debouncer();
  }
  render() {
    const suggests = [];
    for (let i = 0; i < this.state.suggestions.length; i++) {
      const style = classNames('search-option', {'search-highlighted-option': this.state.selected_index === i});
      suggests.push(<div key={i} className={style}>
        <a href={this.state.suggestions[i].url}>{this.state.suggestions[i].subject}</a>
      </div>);
    }
    const panelStyle = {};
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
}

HeaderSearchBox.propTypes = {
  query: PropTypes.string
};
