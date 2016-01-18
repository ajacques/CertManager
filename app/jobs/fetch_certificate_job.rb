class FetchCertificateJob < ActiveJob::Base
  queue_as :public

  def perform(opts)
    importer = CertificateImporter.new opts[:host], opts[:port]
    redis = CertManager::Configuration.redis_client
    certs = importer.get_certs
    redis.set job_id, certs.inspect
  end
end