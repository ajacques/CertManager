class CertificatePart {
  constructor(opts) {
    this.cache = {};
    this.opts = opts.opts;
    this.show_url = opts.show_url;

    if (this.opts.hasOwnProperty('pem')) {
      this.cache['pem'] = this.opts.pem;
    }

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
      return this.cache[format];
    }
    var process = function (result) {
      self.cache[format] = result;
      return result;
    };
    return Ajax.get(this.show_url({id: this.opts.id}, {format: format}), {
      acceptType: 'text/plain'
    }).success(process);
  }

  static from_string(string) {
    return new CertificatePart({pem: string});
  }
}

class Certificate extends CertificatePart {
  constructor(opts) {
    super({opts: opts, show_url: Routes.certificate_path});
  }
  static _analyze_req(body) {
    return {
      acceptType: 'application/json',
      contentType: 'application/x-pem',
      data: body
    }
  }

  _from_chain(result) {
    return this;
  }

  getChain(format) {
    return Ajax.get(Routes.chain_certificate_path({id: this.id}, {format: format})).then(this._from_chain);
  }

  static _from_expanded(blob) {
    return new Certificate(blob);
  }

  static analyze(input) {
    return Ajax.post(Routes.analyze_certificates_path(), this._analyze_req(input)).then(this._from_expanded);
  }

  static _parse_result(result) {
    return result.chain.map(function (f) {
      return new Certificate(f);
    });
  }

  static from_url(host) {
    return AsyncTask.start({
      url: Routes.from_url_certificates_path,
      data: {
        host: host
      }
    }).then(this._parse_result);
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
