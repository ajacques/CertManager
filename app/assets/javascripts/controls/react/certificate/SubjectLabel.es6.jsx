class SubjectLabel extends React.Component {
  render() {
    const array = Object.keys(this.props.subject)
      .filter(key => this.props.subject[key])
      .map(key => `${key}=${this.props.subject[key]}`);
    return <span>{array.join(',')}</span>;
  }
}

SubjectLabel.propTypes = {
  subject: PropTypes.object.isRequired
};
