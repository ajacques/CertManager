module CertHelper
  def cert_chain_tree(cert, &block)
    chain = cert.chain.reverse
    capture_haml do
      build_chain(chain, &block)
    end
  end
  def cert_validate_config(facet, value)
    CertManager::SecurityPolicy.send(facet).secure?(value)
  end
  def cert_show_validate_result(facet, value, header, &block)
    secure = cert_validate_config(facet, value)
    capture_haml do
      haml_tag :tr, class: (if secure then 'bg-success' else 'bg-danger' end) do
        haml_tag :td, header
        integrity = if secure then 'OK' else 'Weak' end
        haml_tag :td, "#{if block.present? then block.call else value end} (#{integrity})"
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