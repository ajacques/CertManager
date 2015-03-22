class HealthCheckController < ApplicationController
  def ping
    render plain: 'OK'
  end

  protected
  def require_login?
    false
  end
end