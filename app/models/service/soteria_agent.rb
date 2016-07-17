class Service::SoteriaAgent < Service
  has_many :agents, through: :memberships
  has_many :memberships, class_name: 'AgentService', foreign_key: :service_id, inverse_of: :service
  service_prop :cert_path, :rotate_container_name
  validates :cert_path, presence: true

  def node_status
    {}
  end

  def agents=(agents)
    super unless agents.any? && agents.first[1].is_a?(String)
    agents = agents.dup
    memberships.each do |member|
      id = member.id.to_s
      if agents.key?(id)
        agents.remove id
      else
        member.delete!
      end
    end
    agents.each do |id, _state|
      memberships << AgentService.new(agent: Agent.find(id.to_i), service: self)
    end
  end

  def node_tags=(args)
    super args.split(' ')
  end
end
