class CertificateBundle::Firefox < CertificateBundle
  after_initialize :set_name

  def self.fetch
    result = RestClient.get('https://mxr.mozilla.org/mozilla/source/security/nss/lib/ckfw/builtins/certdata.txt?raw=1')
    s = new
    s.parse(result)
    s
  end

  def parse(src)
    data = StringIO.new(src)
    last_pub = nil
    loop do
      break if data.eof?
      line = data.readline
      next if line[0] == '#'
      next if line == ''
      split = line.split(' ')
      cmd = split[0]
      next unless cmd == 'CKA_CLASS'
      last_pub = parse_cert(data) if split[2] == 'CKO_CERTIFICATE'
      if split[2] == 'CKO_NSS_TRUST'
        trusted = parse_trust(data)
        add(last_pub) if trusted
      end
    end
  end

  def parse_cert(data)
    loop do
      line = data.readline
      split = line.split(' ')
      next unless split[0] == 'CKA_VALUE'
      return PublicKey.import(read_octal_value(data))
    end
  end

  def parse_trust(data)
    loop do
      line = data.readline
      split = line.split(' ')
      next unless split[0] == 'CKA_TRUST_SERVER_AUTH'
      return split[2] == 'CKT_NSS_TRUSTED_DELEGATOR'
    end
  end

  def read_octal_value(data)
    str = ''
    loop do
      line = data.readline
      break if line == "END\n"
      str += line.split('\\').drop(1).map {|char|
        Integer(char, 8).chr
      }.join('')
    end
    str
  end

  private

  def set_name
    self.name = 'firefox'
  end
end
