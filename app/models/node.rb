class Node
  attr_reader :hostname
  attr_writer :valid, :exists
  attr_accessor :hash, :updated_at

  def initialize(hostname)
    @hostname = hostname
  end

  def valid?
    @valid
  end
  def exists?
    @exists
  end
end