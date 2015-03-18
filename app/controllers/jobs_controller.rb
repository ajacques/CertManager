class JobsController < ApplicationController
  def refresh_all
    ValidateCertificateJob.perform_later
    redirect_to controller: :certificate, action: :index
  end
end