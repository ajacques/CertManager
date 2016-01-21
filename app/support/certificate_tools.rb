class CertificateTools
  def self.extract_certificates(input)
    parts = []
    part = ''
    input.lines.each do |line|
      part += line
      if line.starts_with?('-----END')
        parts.push(part) if line.include?('CERTIFICATE')
        part = ''
      end
    end
    parts
  end

  def self.extract_private_keys(input)
    parts = []
    part = ''
    input.lines.each do |line|
      part += line
      if line.starts_with?('-----END')
        parts.push(part) if line.include?('PRIVATE KEY')
        part = ''
      end
    end
    parts
  end

  def self.find_private_key_for(cert, keys)
    modulus = cert.public_key.modulus
    keys.first { |key|
      key.is_a?(R509::PrivateKey) && key.key.modulus == modulus
    }
  end
end
