class Agent < ActiveRecord::Base
  has_many :services, through: :memberships
  has_many :memberships, class_name: 'AgentService'
  has_many :tags, class_name: 'AgentTag'
  after_initialize :randomize_token

  scope :with_tag, -> (*tags) { joins(:tags).where(tags: {tag: tags}) }

  def image_name
    'soteria-agent:latest'
  end

  def bootstrap(token)
    raise 'Incorrect token' unless token == registration_token
    self.registration_token = nil
    self.access_token = SecureRandom.hex
    self.access_token
  end

  private

  def randomize_token
    self.registration_token ||= SecureRandom.hex
  end
end
