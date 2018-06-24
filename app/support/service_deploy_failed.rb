class ServiceDeployFailed < StandardError
  def initialize(msg)
    super
  end

  def self.raise_faraday(message, faraday)
    msg = "Failed to deploy certificate.\n Status: #{faraday.response[:status]}\n Message: #{message}"
    raise ServiceDeployFailed, msg
  end
end
