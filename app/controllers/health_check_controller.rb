class HealthCheckController < ApplicationController
  skip_before_action :require_login

  def ping
    render plain: 'OK'
  end
end
