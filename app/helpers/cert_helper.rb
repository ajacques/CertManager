module CertHelper
  def cert_chain_tree(cert, &block)
    chain = cert.chain.reverse
    capture_haml do
      build_chain(chain, &block)
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

  def build_chain(chain, &block)
    cert = chain.pop
    return if cert.nil?
    yield cert
    build_chain(chain, &block)
  end
end
