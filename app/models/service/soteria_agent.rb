class Service::SoteriaAgent < Service
  has_many :agents, through: :memberships
  has_many :memberships, class_name: 'AgentService'
  service_prop :cert_path, :rotate_container_name
  validates :cert_path, presence: true
  validates :rotate_container_name, presence: true

  def node_status
    {}
  end
end
