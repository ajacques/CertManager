class CertificateChainInspector extends React.Component {
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

CertificateChainInspector.propTypes = {
  chain: PropTypes.array.isRequired
};
