class AgentsController < ActionController::Base
  def register
    agent = Agent.find_by_registration_token(params[:token])
    response = {
      access_token: SecureRandom.hex
    }
    render json: response
  end

  def bootstrap
    agent = Agent.find_by_access_token(params[:token])
    response = {
      transport: :websocket,
      endpoint: 'ws://certmgr.devvm/agents/stream'
    }
    render json: response
  end
end
