var CertificatesShow = function() {
  'use strict';
  var modalPoint;
  var closure = {};
  var cert = Certificate.find(document.body.getAttribute('data-id'));
  var closeModal = function() {
    ReactDOM.unmountComponentAtNode(modalPoint);
  };
  var popCertWindow = function(evt) {
    var elem = React.render(React.createElement(CertBodyDialog, {modal: cert, close: closeModal}), modalPoint);
    elem.changeFormat(elem.state.format);
    evt.preventDefault();
    return false;
  };
  var clickHistoryLink = function(event) {
    var id = event.currentTarget.dataset.id;
    var pubkey = PublicKey.find(id);
    var elem = ReactDOM.render(React.createElement(CertBodyDialog, {modal: pubkey, close: closeModal}), modalPoint);
    elem.changeFormat(elem.state.format);
    event.preventDefault();
    return false;
  };
  closure.install = function() {
    // Deprecated
    var link = document.getElementById('cert-data-popup-link');
    modalPoint = document.getElementById('modal');
    link.addEventListener('click', popCertWindow);
    closure.attach_history_links();
  };
  closure.attach_history_links = function() {
    var elems = document.getElementsByClassName('history-link');
    for (var i = 0; i < elems.length; i++) {
      elems[i].addEventListener('click', clickHistoryLink);
    }
  };

  closure.install();
};
