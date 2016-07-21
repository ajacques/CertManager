class AgentsController < ApplicationController
  def new
    @agent = Agent.new
    agent_config = Settings::AgentConfig.new
    @signing_key = agent_config.private_key
  end

  def generate_token
    settings = Settings::AgentConfig.new
    token = AgentRegistrationToken.new
    token.key = settings.private_key
    respond_to do |format|
      format.text {
        render text: token.token
      }
    end
  end
end
