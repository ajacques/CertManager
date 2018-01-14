import Ajax from 'utilities/Ajax';

export default class CertificatePart {
  constructor(opts) {
    this.cache = {};
    this.opts = opts.opts;
    this.show_url = opts.show_url;

    if (this.opts.pem) {
      this.cache.pem = this.opts.pem;
    }

    this.subject = this.opts.subject;
    this.to_pem = this.get_format.bind(this, 'pem');
    this.id = this.opts.id;
  }

  to_pem() {
    return this.get_format('pem');
  }

  id() {
    return this.id;
  }

  get_format(format) {
    const self = this;
    if (this.cache.hasOwnProperty(format)) {
      return new Promise(resolve => resolve(this.cache[format]));
    }
    const process = function(result) {
      self.cache[format] = result;
      return result;
    };
    return Ajax.get(this.show_url({id: this.opts.id}, {format: format}), {
      acceptType: 'text/plain'
    }).then(process);
  }

  static from_string(string) {
    return new CertificatePart({pem: string});
  }
}
