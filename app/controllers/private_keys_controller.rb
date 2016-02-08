class PrivateKeysController < ApplicationController
  skip_before_action :verify_authenticity_token
  def analyze
    cert = PrivateKey.import request.body.read
    respond_to do |format|
      format.json {
        render json: cert.to_h
      }
    end
  end
end
