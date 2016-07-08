class Agent < ActiveRecord::Base
  has_many :tags, class_name: 'AgentTag'

  scope :with_tag, -> (*tags) { joins(:tags).where(tags: { tag: tags }) }

  def image_name
    'docker.technowizardry.net/soteria-agent:1'
  end

  def self.register(key, token)
    payload, header = JWT.decode(token, key)

    Agent.create!({
      access_token: SecureRandom.hex
    })
  end
end
