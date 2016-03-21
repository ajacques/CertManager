class AcmeImportJob < ActiveJob::Base
  def perform(certificate)
    @challenge = AcmeChallenge.find_by_certificate_id certificate.id
    @challenge.refresh_status
    if @challenge.status.pending?
      if @challenge.request_verification
        import_cert
      else
        AcmeImportJob.set(wait: 20.seconds).perform_later(certificate)
      end
    elsif @challenge.status.valid?
      import_cert
    end
    @challenge.save!
  rescue Acme::Client::Error::NotFound
    @challenge.delete
  end

  private

  def import_cert
    @challenge.fetch_signed
    @challenge.last_status = :imported
    @challenge.save!
  end
end
