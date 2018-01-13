import Ajax from 'utilities/Ajax';
import CertificatePart from './CertificatePart';
import ModelCache from './ModelCache';

export default class Certificate extends CertificatePart {
  constructor(opts) {
    super({opts: opts, show_url: Routes.certificate_path});
  }
  static _analyze_req(body) {
    return {
      acceptType: 'application/json',
      contentType: 'application/x-pem',
      data: body
    };
  }

  _from_chain(result) {
    result.reverse();
    this.opts = result[0];
    let node = this;
    for (let i = 1; i < result.length; i++) {
      node = node.parent = new Certificate(result[i]);
    }
    return this;
  }

  get chain() {
    const chain = [];
    for (let node = this; node; node = node.parent) {
      chain.push(node);
    }

    return chain;
  }

  get public_key() {
    return this.opts && this.opts.public_key;
  }
  get private_key() {
    return this.opts && this.opts.private_key;
  }

  fetch() {
    return this.getChain('json');
  }

  getChain(format) {
    return Ajax.get(Routes.chain_certificate_path({id: this.id}, {format: format})).then(this._from_chain.bind(this));
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
