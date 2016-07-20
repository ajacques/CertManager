# Enables generation of a signed token agents can use to authenticate
# to this service
class AgentRegistrationToken
  include ActiveModel::Validations
  attr_accessor :key
  attr_reader :expires_at
  validates :key, presence: true

  def initialize
    @expires_at = Time.now.to_i + 1.hour
  end

  def token
    raise 'Not a valid registration token' unless validate
    JWT.encode(jwt_payload, key, 'ES384', exp: expires_at)
  end

  private

  def jwt_payload
    {
    }
  end
end
