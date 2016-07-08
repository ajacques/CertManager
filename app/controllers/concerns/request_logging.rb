module RequestLogging
  extend ActiveSupport::Concern

  included do
    append_before_action :annotate_logs
  end

  protected

  def annotate_logs
    RequestStore.store[:request] = request
    RequestStore.store[:response] = response
  end
end
