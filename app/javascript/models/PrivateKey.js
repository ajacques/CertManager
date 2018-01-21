import Ajax from 'utilities/Ajax';
import CertificatePart from './CertificatePart';

export default class PrivateKey extends CertificatePart {
  constructor(opts) {
    super({
      opts: opts,
      showUrl: Routes.private_key_path
    });
  }
  static _from_expanded(blob) {
    return new PrivateKey(blob);
  }

  static analyze(input) {
    return Ajax.post(Routes.analyze_private_key_path(), {
      acceptType: 'application/json',
      contentType: 'application/x-pem',
      data: input
    }).then(this._from_expanded);
  }
}
