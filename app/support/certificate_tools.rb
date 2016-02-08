class CertificateTools
  def self.extract_certificates(input)
    extract_hunk(input, 'CERTIFICATE')
  end

  def self.extract_private_keys(input)
    extract_hunk(input, 'PRIVATE KEY')
  end

  def self.find_private_key_for(cert, keys)
    modulus = cert.public_key.modulus
    keys.first { |key|
      key.is_a?(R509::PrivateKey) && key.key.modulus == modulus
    }
  end

  def self.extract_hunk(input, marker)
    parts = []
    part = ''
    input.lines.each do |line|
      part += line
      if line.starts_with?('-----END')
        parts.push(part) if line.include?(marker)
        part = ''
      end
    end
    parts
  end
end
