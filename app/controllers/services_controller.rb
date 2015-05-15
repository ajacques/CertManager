class ServicesController < ApplicationController
  def index
    @services = Service.all.includes(:certificate)
  end

  def new
    @service = Service.new
    @service.certificate_id = params[:cert_id].to_i || 0
  end

  def edit
    @service = Service.find params[:id]
  end

  def show
    @service = Service.find(params[:id])
    @node_status = @service.node_status
  end

  def update
    service = Service.find params[:id]
    service.update_attributes! service_params
    redirect_to service
  end

  def deploy
    service = Service.find(params[:id])
    job = DeployServiceJob.perform_later service
    redirect_to deployment_services_path(id: job.job_id)
  end

  def nodes
    salt = SaltClient.new
    salt.login
    render json: salt.get_minions("#{params[:query]}*")['return'].first.map { |k, v| k }
  end

  def create
    redirect_to Service.create service_params
  end

  def destroy
    service = Service.find params[:id]
    service.destroy!
    redirect_to
  end

  def deployment
    redis = CertManager::Configuration.redis_client
    service_id = redis.get("job_#{params[:id]}_service").to_i
    @log = redis.lrange("job_#{params[:id]}_log", 0, -1)
  end

  private
  def service_params
    params[:service].permit(:certificate_id, :cert_path, :after_rotate, :node_group, :deploy_strategy)
  end
end