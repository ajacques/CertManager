class ValidateCertificateJob < ActiveJob::Base
  queue_as :refresh

  def perform
    expiring = Certificate.expiring_in(7.days)
    @redis = CertManager::Configuration.redis_client
    if expiring.any?
      CertificateMailer.expiration_notice('adam@technowizardry.net', expiring).deliver
    end
    find_dirty_cert_files
    @redis.set('CertBgRefresh_LastRun', Time.now.to_f)
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
          exists: nexists[node],
        }
        obj.merge!({
          hash: hash,
          valid: hash == service.certificate.chain_hash
        }) if nexists[node]
        @redis.hset("#{key}_NEW", node, obj.to_json)
      end
      @redis.rename("#{key}_NEW", key)
    end
  end
end