class CertificateChainInspector extends React.Component {
  static propTypes() {
    return {
      chain: PropTypes.array.isRequired
    };
  }
  render() {
    const records = [];
    this.props.chain.forEach((pair, index) => {
      records.push(<CertificatePlaceholder key={pair.id} includePrivate={index === 0} certificate={pair} />);
    });
    return (
      <div>
        {records}
      </div>
    );
  }
}
