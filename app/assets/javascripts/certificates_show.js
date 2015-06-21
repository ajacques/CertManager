var CertificatesShow = function() {
  var modal;
  var currentFormat;
  var downloadLink;
  var id = document.body.getAttribute('data-id');
  var addText = function(pubkey) {
    modal.setBody(pubkey);
  };
  var fetchData = function() {
    PublicKey.find(id, 'pem').done(addText);
  };
  var popCertWindow = function(evt) {
    modal = new ModalDialog();
    modal.setHeader('Certificate Details');
    modal.show();
    fetchData();
    evt.preventDefault();
    return false;
  };
  var changeFormat = function(evt) {
    currentFormat = this.getAttribute('data-format');
    PublicKey.find(id, currentFormat).done(addText);
    downloadLink.href = certificate_path(id, currentFormat);
    evt.preventDefault();
    return false;
  };
  var install = function() {
    var link = document.getElementById('cert-data-popup-link');
    link.addEventListener('click', popCertWindow);
    downloadLink = document.getElementById('modal-download-link');

    var format_links = document.getElementsByClassName('modal-format-selector');
    for (var i = 0; i < format_links.length; i++) {
      var flink = format_links[i];
      flink.addEventListener('click', changeFormat);
    }
  };

  install();
};