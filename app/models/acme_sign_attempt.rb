class AcmeSignAttempt < ApplicationRecord
  has_many :challenges, class_name: 'AcmeChallenge', autosave: true, inverse_of: :sign_attempt
  belongs_to :certificate, autosave: true
  belongs_to :private_key
  belongs_to :imported_key, class_name: 'PublicKey', autosave: true
  WORKING_STATUSES = %w[unchecked unknown pending_verification importing working]
  validates :last_status, inclusion: { in: WORKING_STATUSES + %w[aborted errored failed imported valid] }

  def status
    ActiveSupport::StringInquirer.new last_status
  end

  def status_complete?
    !(status.unchecked? || status.working?)
  end

  delegate :errored?, to: :status

  def problem?
    status.failed? || status.errored?
  end

  def successful?
    status.imported?
  end

  # Status Handlers
  def report_error(error)
    self.last_status = 'errored'
    self.status_message = "#{error}\n#{error.backtrace.first}"
  end

  def self.acme_client
    Settings::LetsEncrypt.new.build_client
  end

  def request_cert
    base_csr = certificate.generate_csr
    acme_order.finalize csr: base_csr
    self.last_status = 'importing'
  end

  def fetch_signed
    signed = AcmeSignAttempt.acme_client.new_certificate certificate.generate_csr
    set = ImportSet.from_array signed.x509_fullchain
    set.import
    set.promote_all_to_certificates nil # TODO: Add import identity correctly

    self.imported_key = set.public_keys.first

    imported_key
  end

  def self.create_for_certificate(certificate, settings)
    attempt = certificate.inflight_acme_sign_attempt
    unless attempt
      attempt = AcmeSignAttempt.new(
        acme_endpoint: settings.endpoint,
        certificate: certificate,
        private_key: settings.private_key
      )
      certificate.inflight_acme_sign_attempt = attempt
      domains = certificate.to_csr.domain_names
      order = acme_client.new_order identifiers: domains
      order.authorizations.each do |auth|
        challenge = AcmeChallenge.from_authorization(attempt, auth)
        attempt.challenges << challenge
      end
      attempt.order_uri = order.url
      @_internal_order = order
    end
    attempt
  end

  private

  def acme_order
    @_internal_order ||= acme_client.order order: order_uri
  end
end
