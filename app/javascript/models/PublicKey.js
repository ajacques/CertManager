import CertificatePart from './CertificatePart';
import ModelCache from './ModelCache';

export default class PublicKey extends CertificatePart {
  constructor(opts) {
    super({
      opts: opts,
      showUrl: Routes.public_key_path
    });
  }

  static find(id) {
    return ModelCache.get(PublicKey, id);
  }
}
