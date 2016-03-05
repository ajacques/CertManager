var CertificatesImport = function() {
  'use strict';
  var button = document.getElementById('import-button');
  var box = document.getElementById('import-url');
  var indicator = document.getElementById('import-indicator');
  var import_component;
  var certificates = [];
  var id = 0;
  var append_certs = function(keys) {
    indicator.classList.add('hidden');
    keys.forEach(function(f) {
      certificates.push({
        key: 'i' + (id++),
        state: 'loaded',
        certificate: {
          state: 'loaded',
          parsed: f,
          value: f.opts.pem + '\n'
        }
      });
    });
    import_component.setState({certificates: certificates});
  };
  var import_click = function(evt) {
    evt.preventDefault();
    var url = box.value;
    if (url !== '') {
      indicator.classList.remove('hidden');
      Certificate.from_url(url).then(append_certs);
    }
    return false;
  };
  var handle_remove = function(key) {
    var index = certificates.findIndex(function(f) { return f.key === key; });
    certificates.splice(index, 1);
    import_component.setState({certificates: certificates});
  };
  function handle_analyze(root, match) {
    return function(result) {
      if (result.opts.id !== undefined) {
        root['cert_id'] = result.opts.id;
      }
      match['parsed'] = result;
      match['state'] = 'loaded';
      import_component.setState({certificates: certificates});
    };
  }
  function findCertById(id) {
    for (var i = 0; i < certificates.length; i++) {
      if (certificates[i].cert_id === id) {
        return certificates[i];
      }
    }
    return null;
  }
  function findCertByFingerprint(fingerprint) {
    for (var i = 0; i < certificates.length; i++) {
      if (certificates[i].fingerprint === fingerprint) {
        return certificates[i];
      }
    }
    return null;
  }
  function handlePrivateKeyAnalyze(root) {
    var private_key = root['private_key'];
    return function(result) {
      if (result.opts.public_keys.length >= 1) {
        var cert = findCertById(result.opts.public_keys[0].id);
        if (cert === null) {
          cert = findCertByFingerprint(result.opts.fingerprint);
        }
        if (cert !== null) {
          // Race condition. use filter
          certificates = certificates.filter(function(f) {
            return f !== root;
          });
          private_key = cert['private_key'] = {
            value: private_key.value
          };
        } else {
          root['cert_id'] = result.opts.public_keys[0].id;
        }
      }
      private_key['parsed'] = result;
      private_key['state'] = 'loaded';
      import_component.setState({certificates: certificates});
    };
  }
  var update = function(body) {
    var item = {
      state: 'fetching',
      value: body.value
    };
    var cert = {
      state: 'fetching',
      key: body.key,
      certificate: undefined,
      private_key: undefined
    };
    if (body.type === 'CERTIFICATE') {
      cert['certificate'] = item;
      Certificate.analyze(body.value).then(handle_analyze(cert, item));
    } else if (body.type === 'RSA PRIVATE KEY') {
      cert['private_key'] = item;
      PrivateKey.analyze(body.value).then(handlePrivateKeyAnalyze(cert));
    }
    certificates.push(cert);
  };

  import_component = React.createElement(CertImportBox, {update: update, onRemove: handle_remove});

  import_component = ReactDOM.render(import_component, document.getElementById('import-box-attach'));

  button.addEventListener('click', import_click);
};
