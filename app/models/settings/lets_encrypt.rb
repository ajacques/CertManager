class Settings::LetsEncrypt < Group
  attr_reader :private_key, :endpoint

  def initialize(key, endpoint)
    @private_key = key
    @endpoint = endpoint
  end
end