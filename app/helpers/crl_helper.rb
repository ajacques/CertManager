require 'net/http'
require 'digest/sha1'

module CrlHelper
  def check_status(crt)
    result = []
    crt.crl_endpoints.each do |uri|
       result << fetch_crl(uri).verify(crt.public_key.public_key)
    end
    result
  end

  private
  def fetch_crl(uri)
    crl = cached(redis_key(uri))
    return R509::CRL::SignedList.new(crl) if crl
    url = URI.parse(uri)
    res = Net::HTTP.get_response(url)
    crl = R509::CRL::SignedList.new(res.body)
    cache_crl(uri, crl)
    crl
  end
  def cached(key)
    client = redis_client
    client.get(key)
  end
  def cache_crl(uri, crl)
    time = (crl.next_update - Time.now).to_i
    redis_client.setex(redis_key(uri), time, crl.to_s)
  end
  def redis_key(uri)
    "crl_#{Digest::SHA1.hexdigest(uri)}"
  end
  def redis_client
    Redis.new CertManager::Configuration.redis.symbolize_keys
  end
end