module CertHelper
  def cert_chain_tree(cert, &block)
    capture_haml do
      build_chain(cert, &block)
    end
  end

  def cert_validate_config(facet, value)
    SecurityPolicy.send(facet).secure?(value)
  end

  def cert_show_validate_policy(facet, value, header, &block)
    secure = cert_validate_config(facet, value)
    cert_show_validate_result(secure, header, &block)
  end

  def cert_show_validate_result(bool, header, &block)
    capture_haml do
      haml_tag :tr, class: (bool ? 'bg-success' : 'bg-danger') do
        haml_tag :td, header
        integrity = bool ? 'OK' : 'Weak'
        text = yield if block.present?
        haml_tag :td, "#{text} (#{integrity})"
      end
    end
  end

  private

  def build_chain(cert, &block)
    # Terminal case: Self signed certificates
    issuer = cert.issuer
    if issuer
      build_chain(issuer, &block) unless issuer == cert
    else
      yield StubCertificate.new subject: cert.public_key.issuer_subject
    end
    yield cert
  end
end
