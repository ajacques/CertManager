class ServicesController < ApplicationController
  def index
    @services = Service.all.includes(:subject_alternate_names, :subjects)
  end

  def new
    @selected_cert_id = params[:cert_id].to_i || 0
  end

  def show
    @service = Service.find(params[:id])
  end

  def deploy
    service = Service.find(params[:id])
    job = DeployServiceJob.perform_later service
    redirect_to deployment_service_index_path(id: job.job_id)
  end

  def nodes
    salt = SaltClient.new
    salt.login
    render json: salt.get_minions("#{params[:query]}*")['return'].first.map {|k,v| k }
  end

  def create
    cert = Certificate.find(params[:certificate])
    service = Service.create(params.permit(:cert_path, :after_rotate, :node_group).merge({certificate: cert}))
    #service.certificate = cert
    service.save!
    redirect_to service
  end

  def deployment
    redis = CertManager::Configuration.redis_client
    service_id = redis.get("job_#{params[:id]}_service").to_i
    @log = redis.lrange("job_#{params[:id]}_log", 0, -1)
  end
end