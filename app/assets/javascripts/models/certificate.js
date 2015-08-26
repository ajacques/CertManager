(function(root) {
  'use strict';
  var analyze_req = function(body) {
    return {
      url: Routes.analyze_certificates_path(),
      dataType: 'json',
      method: 'POST',
      contentType: 'application/x-pem',
      data: body
    }
  };
  var resolved_promise = function(result) {
    var deferred = $.Deferred();

    deferred.resolve(result);
    return deferred.promise();
  };
  var proto = root.Certificate = function(opts) {
    var self = this;
    var cache = {};

    var build_request = function(format) {
      if (opts.hasOwnProperty('id')) {
        return {
          url: Routes.certificate_path({id: opts.id}, {format: format}),
          dataType: 'text'
        };
      }
    };

    self.get_format = function(format) {
      if (cache.hasOwnProperty(format)) {
        return resolved_promise(cache[format]);
      }
      var process = function(result) {
        cache[format] = result;
        return resolved_promise(result);
      };
      return $.ajax(build_request(format)).success(process);
    };

    self.subject = opts.subject;
    self.to_pem = self.get_format.bind(self, 'pem');
    self.id = opts.id;
  };
  var parse_cert_data = function(resp) {
    return resolved_promise(new proto(resp));
  };

  proto.from_string = function(string) {
    return new Certificate({pem: string});
  };

  proto.find = function(id) {
    return new Certificate({id: id});
  };

  proto.analyze = function(input) {
    return $.ajax(analyze_req(input)).then(parse_cert_data);
  };

  proto.from_url = function(host) {
    var process = function(result) {
      var deferred = $.Deferred();

      var keys = result.map(Certificate.from_object);

      deferred.resolve(keys);
      return deferred.promise();
    };
    var ajax = function() {
      return $.ajax({
        url: Routes.import_from_url_certificates_path(),
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

})(this);

