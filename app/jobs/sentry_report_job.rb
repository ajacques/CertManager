class SentryReportJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveJob::DeserializationError) { |e| Rails.logger.error e }

  def perform(event)
    Raven.send_event(event)
  end
end
