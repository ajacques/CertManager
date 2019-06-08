class FetchCertificateJob < ApplicationJob
  queue_as :public

  def perform(opts)
    importer = CertificateImporter.new opts[:host], opts[:port]
    certs = importer.fetch_certs
    resp = {
      status: :done,
      chain: certs
    }
    save_result(resp)
  rescue StandardError => e
    resp = {
      status: :fail,
      message: e.message
    }
    save_result(resp)
  end

  private

  def save_result(result)
    redis = CertManager::Configuration.redis_client
    redis.set job_id, JSON.dump(result)
  end
end
