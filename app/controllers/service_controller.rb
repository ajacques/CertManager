class ServiceController < ApplicationController
  def index
    @services = Service.all
  end

  def new
  end

  def show
    @service = Service.find(params[:id])
  end

  def deploy
    service = Service.find(params[:id])
    DeployCertificateJob.new(service).enqueue
    redirect_to service
  end

  def create
    cert = Certificate.find(params[:certificate])
    service = Service.create(params.permit(:cert_path, :after_rotate))
    service.certificate = cert
    service.save!
    redirect_to service
  end
end