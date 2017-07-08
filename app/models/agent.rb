class Agent < ApplicationRecord
  has_many :tags, class_name: 'AgentTag'
  has_many :services, through: :memberships
  has_many :memberships, class_name: 'AgentService'

  scope :with_tag, ->(*tags) { joins(:tags).where(tags: { tag: tags }) }

  def image_name
    'docker.technowizardry.net/soteria-agent:1'
  end

  def last_sync_long_ago?
    last_synced_at.nil? || last_synced_at < 3.days.ago
  end

  def synced!
    update_attributes! last_synced_at: Time.now.utc
  end

  def self.register(key, token)
    _payload, _header = JWT.decode(token, key)

    Agent.create! access_token: SecureRandom.hex
  rescue JWT::DecodeError
    raise NotAuthorized
  end
end
