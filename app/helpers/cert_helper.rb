module CertHelper
  def cert_chain_tree(cert, &block)
    chain = cert.cert_chain.reverse
    capture_haml do
      build_chain(chain, &block)
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