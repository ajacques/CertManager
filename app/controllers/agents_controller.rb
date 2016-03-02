class AgentsController < ActionController::Base
  attr_reader :agent
  before_filter :check_agent_key, except: [:register]

  def register
    agent = Agent.find_by_registration_token(params[:token])
    response = {
      access_token: SecureRandom.hex
    }
    render json: response
  end

  def bootstrap
    response = {
      transport: :http_poll,
      endpoints: {
        command_stream: agent_command_stream_url(host: 'certmgr.devvm', port: 80)
      }
    }
    render json: response
  end

  # TODO: Migrate to expose this using ServicesController
  def cert_chain
    service = Service.find(params[:id])
    response = service.certificate.full_chain(true)
    render json: response
  end

  def command_stream
    services = agent.services

    service_manifest = services.map do |service|
      {
        id: service.id,
        url: agent_service_url(service, host: 'certmgr.devvm', port: 80),
        path: service.cert_path,
        after_action: {
          type: :docker,
          container_name: 'nginx',
          signal: 'HUP'
        },
        hash: {
          algorithm: :sha256,
          value: service.certificate.chain_hash
        }
      }
    end

    response = {
      continuation: {
        abort: false,
        refresh: 10
      },
      services: service_manifest
    }
    render json: response
  end

  private

  def check_agent_key
    header = request.authorization
    raise NotAuthorized unless header
    split = header.split(' ')
    raise NotAuthorized unless split[0] == 'Bearer'
    key = split[1]
    @agent = Agent.find_by_access_token(key)
  end
end
