'use strict';
var PublicKey = function(id) {
  var self = this;
  var cache = {};

  self.get_format = function(format) {
    if (cache.hasOwnProperty(format)) {
      var deferred = $.Deferred();

      deferred.resolve(cache[format]);
      return deferred.promise();
    }
    var process = function(result) {
      var deferred = $.Deferred();

      cache[format] = result;
      deferred.resolve(result);
      return deferred.promise();
    };
    return $.ajax({
      url: certificate_path(id, format),
      dataType: 'text'
    }).success(process);
  };

  self.to_pem = self.get_format.bind(self, 'pem');
  self.id = id;
};

PublicKey.from_string = function(string) {
  return new PublicKey({to_pem: string});
};

PublicKey.from_object = function(object) {
  return new PublicKey(object);
};

PublicKey.find = function(id) {
  return new PublicKey(id);
};

var import_from_url = function(host) {
  var process = function(result) {
    var deferred = $.Deferred();

    var keys = result.map(PublicKey.from_object);

    deferred.resolve(keys);
    return deferred.promise();
  };
  var ajax = function() {
    return $.ajax({
      url: fetch_key_path(),
      method: 'POST',
      dataType: 'json',
      data: {
        host: host,
        properties: [
          'to_pem'
        ]
      }
    });
  };
  return ajax().done(process);
};
