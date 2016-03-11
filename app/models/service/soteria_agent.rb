class Service::SoteriaAgent < Service
  has_many :agents, through: :memberships
  has_many :memberships, class_name: 'AgentService'
  service_prop :cert_path, :rotate_container_name

  def node_status
    {}
  end
end
