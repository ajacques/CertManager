var CertificatesImport = function() {
  'use strict';
  var button = document.getElementById('import-button');
  var box = document.getElementById('import-url');
  var result = document.getElementById('cert-body');
  var import_component;
  var certificates = [];
  var append_certs = function(keys) {
    var array = [];
    // ?!
    keys.forEach(function(f) {
      import_component.appendCertificate(f);
      f.to_pem().done(function(g) {
        array.push(g);
      });
    });
    //result.value = array.join('\r\n');
  };
  var import_click = function(evt) {
    evt.preventDefault();
    var url = box.value;
    if (url !== '') {
      Certificate.from_url(url).then(append_certs);
    }
    return false;
  };
  var handle_analyze = function(match) {
    return function(result) {
      match['parsed'] = result;
      delete match.fetching;
      //import_component.removeChunk(match);
    };
  };
  var update = function(body) {
    body['fetching'] = true;
    var cert = Certificate.analyze(body.value);
    cert.then(handle_analyze(body));
  };

  import_component = React.createElement(CertImportBox, {update: update});

  import_component = ReactDOM.render(import_component, document.getElementById('import-box-attach'));

  button.addEventListener('click', import_click);
};
