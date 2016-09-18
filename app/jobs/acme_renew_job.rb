class AcmeRenewJob < ActiveJob::Base
  attr_reader :cert

  def perform(cert)
    @cert = cert
    start_attempt unless cert.inflight_acme_sign_attempt
  end

  private

  def start_attempt
    settings = Settings::LetsEncrypt.new
    attempt = AcmeSignAttempt.create_for_certificate cert, settings
    cert.inflight_acme_sign_attempt = attempt
    cert.save!
  end
end
