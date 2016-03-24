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
          elsif command == 'Signature Algorithm' && errors.include?(:hash_algorithm)
            hclass = 'bg-danger'
            error = '(Insecure hash algorithm)'
          elsif command == 'Public-Key' && errors.include?(:bit_length)
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
    hash = csr.signature_algorithm
    errors = []
    errors << :subject if csr.subject.to_s == ''
    errors << :hash_algorithm if SecurityPolicy.hash_algorithm.insecure?(hash.gsub('WithRSAEncryption', ''))
    errors << :bit_length if csr.rsa? && SecurityPolicy.bit_length.insecure?(csr.bit_length)
    errors
  end

  def key_usage_option_tag(name)
    key_usage_option_tag_impl 'key_usage', name
  end

  def extended_key_usage_option_tag(name)
    key_usage_option_tag_impl 'extended_key_usage', name
  end

  private

  def key_usage_option_tag_impl(group, name)
    capture_haml do
      haml_tag :div, class: 'checkbox' do
        haml_tag :label do
          haml_tag :input, type: 'checkbox', name: "public_key[#{group}][]", value: name
          haml_tag :span, t("attributes.#{group}.#{name}")
        end
      end
    end
  end
end
