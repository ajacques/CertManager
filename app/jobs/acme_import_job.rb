class AcmeImportJob < ActiveJob::Base
  attr_reader :attempt

  def perform(attempt)
    @attempt = attempt
    attempt.last_checked_at = Time.now
    attempt.last_status = 'working'
    refresh_all
    if attempt.challenges.empty?
      attempt.last_status = 'failed'
      return
    end
    if any_failed?
      attempt.last_status = 'failed'
      return
    end
    if all_succeeded?
      attempt.last_status = 'valid'
      import_cert
    else
      AcmeImportJob.set(wait: 20.seconds).perform_later(attempt)
    end
  rescue StandardError => err
    attempt.last_status = 'errored'
    attempt.status_message = err.to_s
    raise err
  ensure
    attempt.save!
  end

  private

  def refresh_all
    attempt.challenges.each do |challenge|
      attempt_challenge(challenge)
    end
  end

  def any_failed?
    attempt.challenges.any? do |challenge|
      challenge.status.invalid?
    end
  end

  def all_succeeded?
    attempt.challenges.all? do |challenge|
      challenge.status.valid?
    end
  end

  def attempt_challenge(challenge)
    challenge.refresh_status
    return unless challenge.status.pending?
    challenge.request_verification
  rescue Acme::Client::Error::NotFound
    challenge.delete
  ensure
    challenge.save!
  end

  def import_cert
    attempt.fetch_signed
    attempt.certificate.inflight_acme_sign_attempt = nil
    attempt.last_status = :imported
  end
end
