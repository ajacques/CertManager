class AgentsController < ApplicationController
  def new
    @agent = Agent.new
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
