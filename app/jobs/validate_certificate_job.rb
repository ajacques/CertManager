class ValidateCertificateJob < ApplicationJob
  queue_as :refresh
  attr_reader :redis
  after_perform :update_tick

  def initialize(*args)
    super
    @redis = CertManager::Configuration.redis_client
  end

  def perform
    expiring_certs.each do |cert|
      next unless know_how_to_renew? cert
      next if cert.inflight_acme_sign_attempt

      # TODO: Use job from DB
      AcmeRenewJob.perform_later(cert)
    end
  end

  private

  def know_how_to_renew?(cert)
    cert.auto_renewal_strategy.present?
  end

  def expiring_certs
    Certificate.owned.expiring_in(30.days).deployed_with_service
  end

  def update_tick
    redis.set('CertBgRefresh_LastRun', Time.now.to_f)
  end
end
