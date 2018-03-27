class AcmeRenewJob < ApplicationJob
  attr_reader :cert

  def perform(cert)
    @cert = cert
    if should_start_renewal cert
      start_attempt
      AcmeImportJob.perform_later(cert.inflight_acme_sign_attempt)
    end
  end

  private

  def should_start_renewal(cert)
    return false if cert.inflight_acme_sign_attempt

    threshold = Time.now.utc - 6.hours
    recent_attempts = cert.acme_sign_attempts.where('created_at > ? ', threshold).count

    # Throttling - retry every 6 hours
    recent_attempts.zero?
  end

  def start_attempt
    settings = Settings::LetsEncrypt.new
    attempt = AcmeSignAttempt.create_for_certificate cert, settings
    cert.inflight_acme_sign_attempt = attempt
    cert.save!
  end
end
