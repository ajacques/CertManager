class Agent < ActiveRecord::Base
  has_many :services, through: :memberships
  has_many :memberships, class_name: 'AgentService'
end
