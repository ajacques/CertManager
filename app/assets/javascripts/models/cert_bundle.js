(function(root) {
  'use strict';

  root.CertBundle = function(data) {
    var regex = /-----BEGIN ([A-Z ]+)-----[\r\n]{1,2}[a-zA-Z0-9=/+\r\n]+-----END ([A-Z ]+)-----[\r\n]{1,2}/g;
    var groups = [];

    var rmatch;
    while ((rmatch = regex.exec(data)) !== null) {
      groups.push({
        index: rmatch.index,
        end: rmatch.index + rmatch[0].length,
        type: rmatch[1],
        value: rmatch[0]
      });
    }

    this.keys = groups.filter(function(l) {
      return l.type === 'RSA PRIVATE KEY';
    });
    this.certs = groups.filter(function(l) {
      return l.type === 'CERTIFICATE';
    });
    this.unknown = groups.filter(function(l) {
      return l.type !== 'CERTIFICATE';
    });
    this.all = groups;
  };
})(this);
