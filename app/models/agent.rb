class Agent < ActiveRecord::Base
  has_many :tags, class_name: 'AgentTag'

  scope :with_tag, -> (*tags) { joins(:tags).where(tags: { tag: tags }) }

  def image_name
    'docker.technowizardry.net/soteria-agent:1'
  end

  def last_sync_long_ago?
    last_synced_at.nil? || last_synced_at < 3.days.ago
  end

  def synced!
    update_attributes! last_synced_at: Time.now.utc
  end

  def services
    []
  end

  def self.register(key, token)
    _payload, _header = JWT.decode(token, key)

    Agent.create! access_token: SecureRandom.hex
  end
end
