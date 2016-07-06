class FetchCertificateJob < ActiveJob::Base
  queue_as :public

  def perform(opts)
    importer = CertificateImporter.new opts[:host], opts[:port]
    certs = importer.fetch_certs
    resp = {
      status: :done,
      chain: certs
    }
    save_result(resp)
  rescue Exception => ex
    resp = {
      status: :fail,
      message: ex.message
    }
    save_result(resp)
  end

  private

  def save_result(result)
    redis = CertManager::Configuration.redis_client
    redis.set job_id, Marshal.dump(result)
  end
end
