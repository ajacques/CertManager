class Agent < ActiveRecord::Base
  has_many :services, through: :memberships
  has_many :memberships, class_name: 'AgentService'
  has_many :tags, class_name: 'AgentTag'
  after_initialize :randomize_token

  scope :with_tag, -> (*tags) { joins(:tags).where(tags: { tag: tags }) }

  def image_name
    'docker.technowizardry.net/soteria-agent:1'
  end

  def register_token
    key = PrivateKey.find(1)
    JWT.encode({host: 'foobar.devvm', date: Time.now.utc, tags: {test: true}}, key, 'RS256')
  end

  def bootstrap(token)
    raise 'Incorrect token' unless token == registration_token
    #self.registration_token = nil
    self.access_token = SecureRandom.hex
    access_token
  end

  private

  def randomize_token
    self.registration_token ||= SecureRandom.hex
  end
end
