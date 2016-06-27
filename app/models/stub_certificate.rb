class StubCertificate
  attr_reader :subject

  def initialize(subject:)
    @subject = subject
  end

  def stub?
    true
  end

  delegate :to_s, to: :subject
end