class AcmeSignAttemptsController < ApplicationController
  def show
    @attempt = AcmeSignAttempt.find(params[:id])
    redirect_to prove_ownership_certificate_path(@attempt.certificate) unless @attempt
  end

  def destroy
    attempt = AcmeSignAttempt.find(params[:id])
    attempt.certificate.inflight_acme_sign_attempt = nil
    attempt.last_status = 'aborted'
    attempt.save!
    redirect_to acme_sign_attempt_path(attempt)
  end
end
