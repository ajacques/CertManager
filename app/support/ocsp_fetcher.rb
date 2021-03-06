require 'net/http'
require 'digest/sha1'

module OcspFetcher
  class << self
    def fetch_ocsp(uri, certificate)
      request = OpenSSL::OCSP::Request.new
      request.add_certid(cert_id(certificate))
      req_uri = URI("#{uri}/#{URI.encode_www_form_component(certificate.public_key.cert.to_pem.strip)}")
      resp = Net::HTTP.get_response(req_uri)
      parsed_resp = OpenSSL::OCSP::Response.new(resp.body)
      parsed_resp.inspect
    end

    def cert_id(cert)
      OpenSSL::OCSP::CertificateId.new(cert.public_key.cert, cert.issuer.public_key.cert)
    end

    private

    def cached(key)
      client = redis_client
      client.get(key)
    end

    def redis_key(_cert)
      "ocsp_#{Digest::SHA1.hexdigest(uri)}"
    end

    def redis_client
      Redis.new CertManager::Configuration.redis.symbolize_keys
    end
  end
end
