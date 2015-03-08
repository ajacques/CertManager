require 'app/security_policy'

module CsrHelper
  def explain_csr(csr)
    description = OpenSSL::X509::Request.new(csr.to_pem).to_text.lines
    errors = validate_csr(csr)
    capture_haml do
      haml_tag :div, class: 'csr certificate' do
        description.each do |line|
          indent = '&nbsp;' * (line.size - line.lstrip.size)
          command = line[0, line.index(':')].lstrip
          if command == 'Subject' 
            if errors.include?(:subject)
              hclass = 'bg-danger'
              error = '(Empty subject. May be rejected by the authority)'
            else
              hclass = 'bg-success'
            end
          elsif command == 'Signature Algorithm' and errors.include?(:hash_algorithm)
            hclass = 'bg-danger'
            error = '(Insecure hash algorithm)'
          elsif command == 'Public-Key' and errors.include?(:bit_length)
            hclass = 'bg-danger'
            error = '(Insecure bit length)'
          end
          haml_tag :div, class: hclass do
            haml_tag :span, raw("#{indent}#{line.strip}")
            haml_tag :span, error if error
          end
        end
      end
    end
  end
  def validate_csr(csr)
    hash = csr.signature_algorithm[0, csr.signature_algorithm.index('With')]
    errors = []
    errors << :subject if csr.subject.to_s == ''
    errors << :hash_algorithm if CertManager::SecurityPolicy.hash_algorithms.insecure?(hash)
    errors << :bit_length if CertManager::SecurityPolicy.bit_lengths.insecure?(csr.bit_length)
    errors
  end
end