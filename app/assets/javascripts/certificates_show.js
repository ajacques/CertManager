var CertificatesShow = function() {
  var modal;
  var addText = function(pubkey) {
    modal.setBody(pubkey);
  };
  var fetchData = function() {
    PublicKey.find(1, 'pem').done(addText);
  };
  var popCertWindow = function(evt) {
    modal = new ModalDialog();
    modal.setHeader('Certificate Details');
    modal.show();
    fetchData();
    evt.preventDefault();
    return false;
  };
  var install = function() {
    var link = document.getElementById('cert-data-popup-link');
    link.addEventListener('click', popCertWindow);
  };

  install();
};