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
  var handle_remove = function(key) {
    var index = certificates.findIndex(function(f) { return f.key === key; });
    certificates.splice(index, 1);
    import_component.setState({certificates: certificates});
  };
  var handle_analyze = function(match) {
    return function(result) {
      match['parsed'] = result;
      match['state'] = 'loaded';
      import_component.setState({certificates: certificates});
    };
  };
  var update = function(body) {
    if (certificates.find(function(f) { return body.value === f.value}) !== undefined) {
      return;
    }
    body['state'] = 'fetching';
    certificates.push(body);
    var cert = Certificate.analyze(body.value);
    cert.then(handle_analyze(body));
  };

  import_component = React.createElement(CertImportBox, {update: update, onRemove: handle_remove});

  import_component = ReactDOM.render(import_component, document.getElementById('import-box-attach'));

  button.addEventListener('click', import_click);
};
