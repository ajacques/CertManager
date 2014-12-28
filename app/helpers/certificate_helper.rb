module CertificateHelper
  def extract_certificates(input)
    parts = []
    part = ''
    input.lines.each { |line|
      part = part + line
      if line.starts_with?('-----END')
        if line.include?('CERTIFICATE')
          parts.push(R509::Cert.new cert: part)
        elsif line.include?('RSA PRIVATE KEY')
          #parts.push(OpenSSL::PKey::RSA.new part)
        else
          parts.push(part)
        end
        part = ''
      end
    }
    parts
  end
end