class FetchCertificateJob < ActiveJob::Base
  queue_as :public

  def perform(opts)
    importer = CertificateImporter.new opts[:host], opts[:port]
    redis = CertManager::Configuration.redis_client
    certs = importer.fetch_certs
    redis.set job_id, Marshal.dump(certs)
  end
end
