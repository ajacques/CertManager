var CertificatesShow = function() {
  'use strict';
  var modalPoint;
  var id = document.body.getAttribute('data-id');
  var cert = PublicKey.find(id);
  var elem;
  var closeModal = function() {
    React.unmountComponentAtNode(modalPoint);
  };
  var popCertWindow = function(evt) {
    elem = React.render(React.createElement(CertBodyDialog, {modal: cert, close: closeModal}), modalPoint);
    elem.changeFormat(elem.state.format);
    evt.preventDefault();
    return false;
  };
  var install = function() {
    var link = document.getElementById('cert-data-popup-link');
    modalPoint = document.getElementById('modal');
    link.addEventListener('click', popCertWindow);
  };

  install();
};