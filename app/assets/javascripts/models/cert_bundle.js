(function(root) {
  'use strict';

  var chunk_valid = function(chunk) {
    return chunk[1] == chunk[3];
  };

  root.CertBundle = function(data) {
    var regex = /-----BEGIN ([A-Z ]+)-----[\r\n]{1,2}([a-zA-Z0-9=/+\r\n]+)-----END ([A-Z ]+)-----[\r\n]{0,2}/g;
    var certs = [];
    var unknown = [];
    var keys = [];

    var chunk;
    while (chunk = regex.exec(data)) {
      if (chunk_valid(chunk)) {
        var match = {
          index: regex.lastIndex - chunk[0].length,
          length: chunk[0].length + 1,
          type: chunk[1],
          value: chunk[0]
        };
        var list = [];
        if (match.type === "CERTIFICATE") {
          list = certs;
        } else {
          list = unknown;
        }
        list.push(match);
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