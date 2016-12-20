/* exported SubjectAltNameList */
class SubjectAltNameList extends React.Component {
  constructor(props) {
    super(props);
    this.addRow = this.addRow.bind(this);
    this.renderRow = this.renderRow.bind(this);
    this.state = {
      names: []
    };
  }
  addRow(event) {
    event.preventDefault();
    const newList = this.state.names.slice();
    newList.push('');
    this.setState({names: newList});
  }
  renderRow() {
    return (
      <input name="certificate[csr_attributes][subject_alternate_names][]"
        className="san-textbox form-control" type="text" onChange={this.handleChange} />
    );
  }
  buttonBar() {
    return <button className="btn btn-inline" onClick={this.addRow}>+</button>;
  }
  render() {
    return (
      <div>
        {this.state.names.map(this.renderRow)}
        {this.buttonBar()}
      </div>
    );
  }
}
