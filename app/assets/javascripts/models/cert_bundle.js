var CertBundle = function(data) {
  'use strict';
  var regex = /-----BEGIN ([A-Z ]+)-----[\n\r]{1,2}([a-zA-Z0-9=/+\r\n]+)-----END ([A-Z ]+)-----/g;
  var certs = data.match(regex);

  this.chunks = certs.map(function(cert) {
    regex.lastIndex = 0;
    return regex.exec(cert);
  });

  for (var chunk : this.chunks) {

  }
};