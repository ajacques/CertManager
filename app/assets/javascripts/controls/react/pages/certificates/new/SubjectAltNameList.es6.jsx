class SubjectAltNameList extends React.Component {
  constructor(props) {
    super(props);
    this.renderRow = this.renderRow.bind(this);
    this.state = {
      names: []
    };
  }
  _textBox() {
    return (
      <input name="certificate[csr_attributes][subject_alternate_names][]" 
        className="san-textbox form-control" type="text" onChange={this.handleChange} />
    );
  }
  renderRow(item, index) {
    return (
      <div>
        {this._textBox()}
      </div>
    );
  }
  render() {
    return (
      <ul>
        {this.state.names.map(this.renderRow)}
        {this._textBox()}
      </ul>
    );
  }
}
