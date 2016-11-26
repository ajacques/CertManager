class AgentsApiController < ActionController::Base
  attr_reader :agent
  append_before_action :check_agent_key, except: [:register]
  include RequestLogging

  def register
    settings = Settings::AgentConfig.new
    token = params[:token]
    agent = Agent.register(settings.private_key, token)
    response = {
      bootstrap_url: agent_bootstrap_url,
      access_token: agent.access_token,
      image_name: agent.image_name
    }
    agent.save!

    render json: response
  rescue NotAuthorized
    render nothing: true, status: :forbidden
  end

  def bootstrap
    response = {
      transport: :http_poll,
      endpoints: {
        sync: agent_sync_url,
        report: agent_report_url
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

  def report
    body = JSON.parse(request.body.read)
    agent.last_hostname = body['hostname']
    # TODO: So insecure
    body['services'].each do |service_id, item|
      record = {
        hostname: body['hostname'],
        updated_at: Time.now,
        exists: true,
        valid: item['state'] == 'valid',
        status: item['state']
      }
      record[:reason] = item['reason'] if item.key? 'reason'
      CertManager::Configuration.redis_client.hset("SERVICE_#{service_id}_NODESTATUS", agent.id, record.to_json)
    end
    agent.save!

    render nothing: true, status: :accepted
  end

  def sync
    services = agent.services

    service_manifest = services.map do |service|
      manifest = service.as_agent_manifest
      manifest[:url] = agent_service_url(service)
      manifest
    end

    response = {
      continuation: {
        abort: false,
        refresh: 60
      },
      services: service_manifest
    }
    agent.synced!
    respond_to do |format|
      format.json {
        render json: response
      }
    end
  end

  private

  def check_agent_key
    header = request.authorization
    raise NotAuthorized unless header
    split = header.split(' ')
    raise NotAuthorized unless split[0] == 'Bearer'
    key = split[1]
    raise NotAuthorized unless key
    @agent = Agent.find_by access_token: key
    raise NotAuthorized unless @agent
  end
end
