class AgentsController < ApplicationController
  def new
    @agent = Agent.new
  end

  def generate_token
    settings = Settings::AgentConfig.new
    input = JSON.parse(request.body.read)
    to_sign = {
      host: request.host,
      date: Time.now.utc,
      tags: input['tags']
    }
    key = settings.private_key
    respond_to do |format|
      format.text {
        render text: JWT.encode(to_sign, key, 'ES384')
      }
    end
  end
end
