export default class CertBundle {
  constructor(data) {
    const regex = /-----BEGIN ([A-Z ]+)-----[\r\n]{1,2}[a-zA-Z0-9=/+\r\n]+-----END ([A-Z ]+)-----[\r\n]{1,2}/g;
    const groups = [];

    let rmatch;
    while ((rmatch = regex.exec(data)) !== null) {
      groups.push({
        end: rmatch.index + rmatch[0].length,
        index: rmatch.index,
        type: rmatch[1],
        value: rmatch[0]
      });
    }

    this.keys = groups.filter(l => l.type === "RSA PRIVATE KEY");
    this.certs = groups.filter(l => l.type === "CERTIFICATE");
    this.unknown = groups.filter(l => l.type !== "CERTIFICATE");
    this.all = groups;
  }
}
