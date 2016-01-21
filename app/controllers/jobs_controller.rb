class JobsController < ApplicationController
  def refresh_all
    ValidateCertificateJob.perform_later
    redirect_to root_path
  end
end
