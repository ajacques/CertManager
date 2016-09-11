class Node
  attr_reader :updated_at
  attr_writer :status
  attr_accessor :hostname, :hash, :updated_at, :valid, :exists, :reason
  alias valid? valid
  alias exists? exists

  def initialize(opts = {})
    opts.each do |key, val|
      send("#{key}=", val) if respond_to? key
    end
  end

  def status
    ActiveSupport::StringInquirer.new @status
  end

  def updated_at=(val)
    @updated_at = if val.is_a? String
                    Time.parse(val)
                  else
                    val
                  end
  end
end
