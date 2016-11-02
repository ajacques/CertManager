class Service::SoteriaAgent < Service
  has_many :agents, through: :memberships
  has_many :memberships, class_name: 'AgentService', foreign_key: :service_id, inverse_of: :service
  service_prop :cert_path, :rotate_container_name
  validates :cert_path, presence: true

  def agent_ids
    agents.map(&:id)
  end

  def deployable?
    false
  end

  def as_agent_manifest
    map = {
      id: id,
      path: cert_path,
      after_action: [],
      hash: {
        algorithm: :sha256,
        value: certificate.chain_hash
      }
    }

    if rotate_container_name
      map[:after_action] << {
        type: :docker,
        container_name: rotate_container_name
      }
    end
    map
  end

  def agent_ids=(agents)
    agents = agents.dup
    memberships.each do |member|
      id = member.id.to_s
      if agents.key?(id)
        agents.remove id
      else
        member.delete
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
