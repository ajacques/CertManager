(function(root) {
  'use strict';

  var chunk_valid = function(chunk) {
    return chunk[1] == chunk[3];
  };

  root.CertBundle = function(data) {
    var regex = /-----BEGIN ([A-Z ]+)-----\n[a-zA-Z0-9=/+\r\n]+\n-----END ([A-Z ]+)-----\n/g;
    var groups = [];

    var rmatch;
    while (rmatch = regex.exec(data)) {
      groups.push({
        index: rmatch.index,
        end: rmatch.index + rmatch[0].length,
        type: rmatch[1],
        value: rmatch[0]
      });
    }

    this.certs = groups.filter(function(l) {
      return l.type === 'CERTIFICATE';
    });
    this.unknown = groups.filter(function(l) {
      return l.type !== 'CERTIFICATE';
    });
    this.all = groups;
  };
})(this);