class Agent < ActiveRecord::Base
  has_many :services, through: :memberships
  has_many :memberships, class_name: 'AgentService'
  after_initialize :randomize_token
  validates :registration_token, presence: true

  def image_name
    'soteria-agent:latest'
  end

  private

  def randomize_token
    self.registration_token ||= SecureRandom.hex
  end
end
