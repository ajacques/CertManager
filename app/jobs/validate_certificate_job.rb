class ValidateCertificateJob < ActiveJob::Base
  queue_as :refresh
  attr_reader :redis

  def initialize(*args)
    super
    @redis = CertManager::Configuration.redis_client
  end

  def perform
    find_dirty_cert_files
    redis.set('CertBgRefresh_LastRun', Time.now.to_f)
  end

  private

  def find_dirty_cert_files
    salt = SaltClient.new
    Service.find_each do |service|
      key = "SERVICE_#{service.id}_NODESTATUS"
      nexists = salt.file_exists?(service.node_group, service.cert_path)
      salt.get_hash(service.node_group, service.cert_path).each do |node, hash|
        obj = {
          update: Time.now,
          exists: nexists[node]
        }
        if nexists[node]
          obj[:hash] = hash
          obj[:valid] = hash == service.certificate.chain_hash
        end
        redis.hset("#{key}_NEW", node, obj.to_json)
      end
      redis.rename("#{key}_NEW", key)
    end
  end
end
