class JobsController < ApplicationController
  def refresh_all
    ValidateCertificateJob.perform_later
    redirect_to root_path
  end

  def refresh_cert_bundle
    bundle_class = params[:bundle_class].constantize
    raise NotAuthorized unless bundle_class < CertificateBundle

    bundle = bundle_class.fetch
    bundle.save!
    bundle.public_keys.each do |pub|
      Certificate.create public_key: pub, created_by: current_user, updated_by: current_user
    end
    redirect_to root_path
  end
end
