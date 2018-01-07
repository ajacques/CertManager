class SubjectLabel extends React.Component {
  static propTypes() {
    return {
      subject: PropTypes.object.isRequired
    };
  }
  render() {
    const array = Object.keys(this.props.subject)
      .filter(key => this.props.subject[key])
      .map(key => `${key}=${this.props.subject[key]}`);
    return <span>{array.join(',')}</span>;
  }
}
