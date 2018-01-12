class ServicesNewOverview extends React.Component {
  constructor(props) {
    super(props);
    this.onCertificateChange = this.onCertificateChange.bind(this);
    this.onChainFetch = this.onChainFetch.bind(this);
    this.state = {
      certificate: null,
      chain: [],
      loaded: false
    };
  }
  componentDidMount() {
    const element = document.getElementById(this.props.certificateSelectId);
    element.addEventListener('change', this.onCertificateChange);
    this.loadCertificateId(element.selectedOptions[0].value);
  }
  shouldComponentUpdate(nextProps, nextState) {
    return (
      this.state.loaded !== nextState.loaded && nextState.loaded ||
      this.state.loading !== nextState.loading
    );
  }

  onChainFetch() {
    this.setState({chain: this.state.certificate.chain, loaded: true});
  }

  loadCertificateId(id) {
    const cert = Certificate.find(parseInt(id, 10));
    cert.fetch().then(this.onChainFetch);
    this.setState({loaded: false, loading: true, certificate: cert});
  }

  // Event Handlers
  onCertificateChange(event) {
    const item = event.target.selectedOptions[0];
    this.loadCertificateId(item.value);
  }

  render() {
    return (
      <div className="certificate">
        <CertificateChainInspector chain={this.state.chain} />
      </div>
    );
  }
}

ServicesNewOverview.propTypes = {
  certificateSelectId: PropTypes.string.isRequired
};
