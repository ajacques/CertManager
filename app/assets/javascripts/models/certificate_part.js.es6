class CertificatePart {
  constructor(opts) {
    this.cache = {};
    this.opts = opts.opts;
    this.show_url = opts.show_url;

    if (opts.hasOwnProperty('to_pem')) {
      this.cache['pem'] = opts.to_pem;
    }

    this.build_request = function (format) {
      if (this.opts.hasOwnProperty('id')) {
        return {
          url: this.show_url({id: this.opts.id}, {format: format}),
          dataType: 'text'
        };
      }
    };

    this.subject = this.opts.subject;
    this.to_pem = this.get_format.bind(this, 'pem');
    this.id = this.opts.id;
  };

  to_pem() {
    return get_format('pem');
  }

  id() {
    return this.id;
  }

  get_format(format) {
    var self = this;
    if (this.cache.hasOwnProperty(format)) {
      return resolved_promise(this.cache[format]);
    }
    var process = function (result) {
      self.cache[format] = result;
      return resolved_promise(result);
    };
    return $.ajax(this.build_request(format)).success(process);
  }

  static from_string(string) {
    return new CertificatePart({pem: string});
  }

  static analyze(input) {
    return $.ajax(analyze_req(input)).then(parse_cert_data);
  }
}

class Certificate extends CertificatePart {
  constructor(opts) {
    super({opts: opts, show_url: Routes.certificate_path});
  }
  static _analyze_req(body) {
    return {
      url: Routes.analyze_certificates_path(),
      dataType: 'json',
      method: 'POST',
      contentType: 'application/x-pem',
      data: body
    }
  }

  static analyze(input) {
    return $.ajax(this._analyze_req(input)).then(parse_cert_data);
  }

  static from_url(host) {
    var promise = $.Deferred();
    var process = function (result) {
      if (result.status !== 'done') {

        return;
      }

      var certs = result.map(function (f) {
        return new Certificate(f);
      });

      promise.resolve(certs);
    };
    $.ajax({
      url: Routes.import_from_url_certificates_path(),
      method: 'POST',
      dataType: 'json',
      data: {
        host: host,
        properties: [
          'to_pem'
        ]
      }
    }).success(process);
    return promise.promise();
  }

  static find(id) {
    return ModelCache.get(Certificate, id);
  }
}

class PublicKey extends CertificatePart {
  constructor(opts) {
    super({opts: opts, show_url: Routes.public_key_path});
  }

  static find(id) {
    return ModelCache.get(PublicKey, id);
  }
}