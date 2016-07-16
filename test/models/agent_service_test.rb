require 'test_helper'

class AgentServiceTest < ActiveSupport::TestCase
  test 'can persist cert path' do
    agent = Service::SoteriaAgent.new
    agent.cert_path = 'foo'
    assert_equal 'foo', agent.cert_path
  end

  test 'properties works' do
    agent = Service::SoteriaAgent.new
    one = agent.properties
    two = agent.properties
    assert_equal one.object_id, two.object_id
  end
end
