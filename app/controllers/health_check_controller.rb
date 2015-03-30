class HealthCheckController < ApplicationController
  skip_before_filter :require_login

  def ping
    render plain: 'OK'
  end
end