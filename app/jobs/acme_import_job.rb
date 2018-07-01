class AcmeImportJob < ApplicationJob
  attr_reader :attempt

  def perform(attempt)
    @attempt = attempt
    attempt.last_checked_at = Time.now
    attempt.last_status = 'working'
    refresh_all
    if attempt.challenges.empty? || any_failed?
      attempt.last_status = 'failed'
      attempt.certificate.inflight_acme_sign_attempt = nil
    elsif all_succeeded?
      attempt.last_status = 'valid'
      log_debug_step 'All challenges succeeded. Importing.'
      import_cert
      DeployCertificateJob.set(wait: 10.seconds).perform_later attempt.certificate
    else
      AcmeImportJob.set(wait: 20.seconds).perform_later(attempt)
    end
  rescue StandardError => err
    attempt.report_error err
    Raven.capture_exception err
    raise err
  ensure
    attempt.save!
  end

  private

  def refresh_all
    log_debug_step 'Checking ACME challenge status.'
    attempt.challenges.each do |challenge|
      attempt_challenge(challenge)
    end
  end

  def log_debug_step(message)
    Raven.breadcrumbs.record do |crumb|
      crumb.level = :info
      crumb.message = message
      crumb.category = 'job.step'
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
    log_debug_step "ACME challenge status for '#{challenge.domain_name}': #{challenge.status}"
    challenge.save!
  end

  def import_cert
    attempt.fetch_signed
    attempt.certificate.inflight_acme_sign_attempt = nil
    attempt.certificate.auto_renewal_strategy = AcmeRenewJob.name
    attempt.last_status = 'imported'
  end
end
