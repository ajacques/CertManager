(function(root) {
  'use strict';

  var chunk_valid = function(chunk) {
    return chunk[1] == chunk[3];
  };

  root.CertBundle = function(data) {
    var start = /-----BEGIN ([A-Z ]+)-----/;
    var middle = /[a-zA-Z0-9=/+\r\n]+/;
    var end = /-----END ([A-Z ]+)-----/;
    var groups = [];

    var group = {
      in_block: false,
      index: 0,
      length: 0,
      values: []
    };
    for (var i = 0; i < data.length; i++) {
      var match;
      var line = data[i];
      if (match = line.match(start)) {
        group = {
          in_block: true,
          index: i,
          length: 1,
          type: match[1],
          values: [
            match[0]
          ]
        };
      } else if (group.in_block && (match = line.match(end))) {
        group.length++;
        group.values.push(match[0]);
        groups.push(group);
        group = {
          in_block: false,
          index: i + 1,
          length: 0,
          values: []
        };
      } else if (group.in_block && (match = line.match(middle))) {
        group.length++;
        group.values.push(match[0])
      } else {
        group.in_block = false;
        group.length++;
        group.values.push(line);
        delete group.type;
      }
    }
    if (group.index < data.length) {
      groups.push(group);
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