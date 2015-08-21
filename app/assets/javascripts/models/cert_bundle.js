var CertBundle = function(data) {
  'use strict';
  var regex = /-----BEGIN ([A-Z ]+)-----[\n\r]{1,2}([a-zA-Z0-9=/+\r\n]+)-----END ([A-Z ]+)-----/g;
  var matches = data.match(regex);
  var certs = [];
  var unknown = [];
  var keys = [];

  var chunks = matches.map(function(cert) {
    regex.lastIndex = 0;
    return regex.exec(cert);
  });

  var chunk_valid = function(chunk) {
    return chunk[1] == chunk[3];
  };

  for (var i = 0; i < chunks.length; i++) {
    var chunk = chunks[i];
    if (chunk_valid(chunk)) {
      if (chunk[1] === "CERTIFICATE") {
        certs.push(chunk[0]);
      } else if (chunk[1] === "RSA PRIVATE KEY") {
        keys.push(chunk[0])
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