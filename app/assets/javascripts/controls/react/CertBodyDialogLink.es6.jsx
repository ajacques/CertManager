class CertBodyDialogLink extends React.Component {
  constructor(props) {
    super(props);
    this.openWindow = this.openWindow.bind(this);
    this.close = this.close.bind(this);
  }
  close() {
    ReactDOM.unmountComponentAtNode(CertBodyDialogLink.modalPoint);
  }
  _getModel() {
    var model = this.props.model;
    if (model.hasOwnProperty('get_format')) {
      return model;
    }
    if (self[model.type] === undefined) {
      return model;
    }
    return self[model.type].find(model.id);
  }
  openWindow(event) {
    event.preventDefault();
    var elem = ReactDOM.render(<CertBodyDialog model={this._getModel()} onClose={this.close} />, CertBodyDialogLink.modalPoint);
    elem.changeFormat(elem.state.format);
    return false;
  }
  render() {
    return (
      <a onClick={this.openWindow} href={Routes.public_key_path({id: this.props.model.id})}>{this.props.children}</a>
    );
  }
}

if (typeof document !== "undefined") {
  CertBodyDialogLink.modalPoint = document.createElement('div');
  document.body.appendChild(CertBodyDialogLink.modalPoint);
}

CertBodyDialogLink.propTypes = {
  model: PropTypes.object.isRequired,
  children: PropTypes.string.isRequired
};
