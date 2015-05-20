var PublicKey = function(pem) {
  var self = this;
  self.to_pem = function() {
    return pem;
  }
};

PublicKey.from_string = function(string) {
  return new PublicKey(string);
};

var import_from_url = function(host, callback) {
  var process = function(result) {
    var deferred = $.Deferred();

    var keys = result.map(PublicKey.from_string);

    deferred.resolve(keys);
    return deferred.promise();
  };
  var ajax = function() {
    return $.ajax({
      url: fetch_key_path(),
      method: 'POST',
      dataType: 'json',
      data: {
        host: host
      }
    });
  };
  return ajax().done(process);
};