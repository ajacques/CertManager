var CertificatesShow = function() {
  'use strict';
  var modalPoint;
  var closure = {};
  var cert = Certificate.find(document.body.getAttribute('data-id'));
  var closeModal = function() {
    ReactDOM.unmountComponentAtNode(modalPoint);
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
    modalPoint = document.getElementById('modal');
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
