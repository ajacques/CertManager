(function(root) {
  'use strict';
  var regex = /-----BEGIN ([A-Z ]+)-----[\r\n]{1,2}([a-zA-Z0-9=/+\r\n]+)-----END ([A-Z ]+)-----/g;

  var chunk_valid = function(chunk) {
    return chunk[1] == chunk[3];
  };

  root.CertBundle = function(data) {
    var matches = data.match(regex);
    var certs = [];
    var unknown = [];
    var keys = [];

    if (matches === null) {
      return;
    }

    var chunks = matches.map(function(cert) {
      regex.lastIndex = 0;
      return regex.exec(cert);
    });

    for (var i = 0; i < chunks.length; i++) {
      var chunk = chunks[i];
      if (chunk_valid(chunk)) {
        if (chunk[1] === "CERTIFICATE") {
          certs.push(chunk[0]);
        } else {
          unknown.push(chunk[0]);
        }
      }
    }

    this.get_certs = function() {
      return certs;
    };
    this.get_keys = function() {
      return keys;
    };
    this.get_unknown = function() {
      return unknown;
    };
  };
})(this);