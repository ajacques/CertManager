class Node
  attr_reader :hostname, :valid, :exists
  attr_writer :valid, :exists
  attr_accessor :hash, :updated_at
  alias valid? valid
  alias exists? exists

  def initialize(hostname)
    @hostname = hostname
  end
end
