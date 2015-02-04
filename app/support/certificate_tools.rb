class CertificateTools
  def self.extract_certificates(input)
    parts = []
    part = ''
    input.lines.each { |line|
      part = part + line
      if line.starts_with?('-----END')
        if line.include?('CERTIFICATE')
          parts.push(R509::Cert.new cert: part)
        elsif line.include?('PRIVATE KEY')
          #parts.push(R509::PrivateKey.new key: part)
        else
          parts.push(part)
        end
        part = ''
      end
    }
    parts
  end
  def self.extract_private_keys(input)
    parts = []
    part = ''
    input.lines.each { |line|
      part = part + line
      if line.starts_with?('-----END')
        if line.include?('CERTIFICATE')
          #parts.push(R509::Cert.new cert: part)
        elsif line.include?('PRIVATE KEY')
          parts.push(R509::PrivateKey.new key: part)
        else
          parts.push(part)
        end
        part = ''
      end
    }
    parts
  end
  def self.find_private_key_for(cert, keys)
    modulus = cert.public_key.modulus
    keys.first { |key|
      key.is_a?(R509::PrivateKey) and key.key.modulus == modulus
    }
  end
end