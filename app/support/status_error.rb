class StatusError < ActiveSupport::StringInquirer
  attr_reader :error

  def initialize(status, error)
    super(status)
    @error = error
  end
end
