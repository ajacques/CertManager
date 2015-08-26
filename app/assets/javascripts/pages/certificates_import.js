var CertificatesImport = function() {
  'use strict';
  var button = document.getElementById('import-button');
  var box = document.getElementById('import-url');
  var result = document.getElementById('cert-body');
  var import_component;
  var certificates = [];
  var append_certs = function(keys) {
    result.value = keys.map(function(f) { return f.to_pem; }).join('\r\n');
  };
  var import_click = function(evt) {
    evt.preventDefault();
    var url = box.value;
    if (url !== '') {
      Certificate.from_url(url).then(append_certs);
    }
    return false;
  };
  var handle_analyze = function(result) {
    certificates.push(result);
    import_component.setState({certificates: certificates});
  };
  var update = function(body) {
    var bundle = new CertBundle(body);
    var certs = bundle.get_certs();
    for (var i = 0; i < certs.length; i++) {
      var cert = Certificate.analyze(certs[i]);
      cert.then(handle_analyze);
    }
  };

  import_component = React.constructAndRenderComponentByID(CertImportBox, {update: update}, 'import-box-attach');

  button.addEventListener('click', import_click);
};