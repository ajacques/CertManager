var PublicKey = function(obj) {
  var self = this;
  self.to_pem = function() {
    return obj.to_pem;
  }
};

PublicKey.from_string = function(string) {
  return new PublicKey({to_pem: string});
};

PublicKey.from_object = function(object) {
  return new PublicKey(object);
};

PublicKey.find = function(id, format) {
  var process = function(result) {
    var deferred = $.Deferred();

    deferred.resolve(new PublicKey());
    return deferred.promise();
  };
  var ajax = function() {
    return $.ajax({
      url: certificate_path(id, format),
      method: 'GET',
      dataType: 'json'
    });
  };
  return ajax().done(process);
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
