class Service::SoteriaAgent < Service
  SIGNALS = %w[HUP USR1].sort.freeze
  has_many :memberships, class_name: 'AgentService', foreign_key: :service_id, inverse_of: :service
  has_many :agents, through: :memberships
  service_prop :cert_path, :rotate_enabled, :rotate

  # Validations
  validates :cert_path, presence: true
  # validates :signal, inclusion: { in: SIGNALS }
  validates :rotate, presence: true, if: :rotate_enabled

  def agent_ids
    agents.map(&:id)
  end

  def deployable?
    false
  end

  alias triggers_post_rotate? rotate_enabled

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

    if triggers_post_rotate?
      map[:after_action] << {
        type: :docker,
        container_name: rotate['container_name'],
        signal: rotate['signal']
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
    agents.each_key do |id|
      memberships << AgentService.new(agent: Agent.find(id.to_i), service: self)
    end
  end
end
