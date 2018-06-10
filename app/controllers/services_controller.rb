class ServicesController < ApplicationController
  def index
    @services = Service.all.includes(:certificate)
    @agents = Agent.all
  end

  def new
    type = pick_service_type
    @service = type.new
    @service.certificate_id = params[:cert_id].to_i || 0
    flash[:error]&.each do |error|
      @service.errors.add error
    end
    case params[:type]
    when 'rancher'
      render 'services/rancher/new'
    else
      render 'services/new'
    end
  end

  def create
    raise NotSupported unless params[:service][:type].in? %w[Service::SoteriaAgent Service::Rancher]
    redirect_to Service.create! service_create_params
  rescue ActiveRecord::RecordInvalid => ex
    flash[:error] = ex.record.errors
    redirect_to action: :new
  end

  def edit
    @service = Service.find params[:id]
  end

  def show
    @service = Service.find params[:id]
    @node_status = @service.node_status
  end

  def update
    service = Service.find params[:id]
    u_params = service_update_params
    u_params[:agent_ids] = params[:service][:agent_ids]

    service.update! u_params
    redirect_to service
  end

  def deploy
    service = Service.find(params[:id])
    job = DeployServiceJob.perform_later service
    redirect_to deployment_services_path(id: job.job_id)
  end

  def destroy
    service = Service.find params[:id]
    service.destroy!
    redirect_to services_path
  end

  def deployment
    redis = CertManager::Configuration.redis_client
    @log = redis.lrange("job_#{params[:id]}_log", 0, -1)
  end

  private

  def pick_service_type
    case params[:type]
    when 'rancher'
      Service::Rancher
    else
      Service::SoteriaAgent
    end
  end

  def service_create_params
    params.require(:service).permit(:type, service_any_params, rotate: %i[container_name signal])
  end

  def service_update_params
    params.require(:service).permit(:cert_path, service_any_params)
  end

  def service_any_params
    svc_params = Set.new(:certificate_id)
    Service::Rancher.service_props.each { |param| svc_params << param }
    Service::SoteriaAgent.service_props.each { |param| svc_params << param }
    svc_params
  end
end
