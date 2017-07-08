class ServicesController < ApplicationController
  def index
    @services = Service.all.includes(:certificate)
    @agents = Agent.all
  end

  def new
    @service = Service::SoteriaAgent.new
    @service.certificate_id = params[:cert_id].to_i || 0
    flash[:error]&.each do |error|
      @service.errors.add error
    end
  end

  def create
    raise NotSupported unless params[:service][:type] == 'Service::SoteriaAgent'
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

    service.update_attributes! u_params
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

  def service_create_params
    params.require(:service).permit(:type, :certificate_id, :cert_path, :rotate_enabled, rotate: %i[container_name signal])
  end

  def service_update_params
    params.require(:service).permit(:cert_path, rotate: %i[container_name signal])
  end
end
