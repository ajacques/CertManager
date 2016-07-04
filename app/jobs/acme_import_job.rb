class AcmeImportJob < ActiveJob::Base
  attr_reader :attempt

  def perform(attempt)
    @attempt = attempt
    refresh_all
    if any_failed?
      attempt.last_status = 'failed'
      return
    end
    if all_succeeded?
      attempt.last_status = 'valid'
      import_cert
    end
  ensure
    attempt.save!
  end

  private

  def refresh_all
    attempt.challenges.each(&:attempt_challenge)
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
    if challenge.status.pending?
      if challenge.request_verification
        import_cert
      else
        AcmeImportJob.set(wait: 20.seconds).perform_later(attempt)
      end
    else
      attempt.acme_checked_at = Time.now
      import_cert if challenge.status.valid?
    end
  rescue Acme::Client::Error::NotFound
    challenge.delete
  end

  def import_cert
    @attempt.fetch_signed
    @attempt.last_status = :imported
  end
end
