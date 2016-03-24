class AcmeSignAttempt
  include ActiveRecord::AttributeAssignment
  attr_accessor :certificate, :challenges

  def initialize(opts = {})
    assign_attributes(opts)
  end

  def status
    ActiveSupport::StringInquirer.new 'unchecked'
  end

  def self.find_by_certificate(certificate, settings)
    challenges = AcmeChallenge.where(certificate_id: certificate.id)
    unless challenges.any?
      challenges = certificate.domain_names.map do |name|
        AcmeChallenge.for_domain(certificate, settings, name)
      end
    end
    new(certificate: certificate, challenges: challenges)
  end
end
