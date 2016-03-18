config = Rails.application.config

logstash = LogStashLogger.new type: :udp, host: 'logstash', port: 5228
# Rails.logger = ActiveSupport::TaggedLogging.new logstash
config.log_level = :debug

class RequestSubscriber < ActiveSupport::LogSubscriber
  class << self
    attr_accessor :logstash
  end

  def process_action(event)
    data = event.payload
    output = LogStash::Event.new
    output.type = 'http_request'
    output[:response] = extract_status(data)
    output[:timing] = {
      total: event.duration,
      view: data[:view_runtime],
      db: data[:db_runtime],
      redis: data[:redis_runtime]
    }
    output[:request] = {
      method: data[:method],
      path: data[:path],
      format: data[:format]
    }
    output[:routing] = {
      controller: data[:controller],
      action: data[:action],
      resource: "#{data[:controller]}##{data[:action]}"
    }
    request = RequestStore.store[:request]
    actor = RequestStore.store[:actor]
    if request
      mg = {
        id: request.env['action_dispatch.request_id'],
        user_agent: request.env['HTTP_USER_AGENT']
      }
      output[:request].merge!(mg)
    end
    if actor.is_a? User
      output[:user] = {
        id: actor.id,
        username: actor.email
      }
    end
    RequestSubscriber.logstash.info(output.to_json)
  end

  def extract_status(payload)
    if (status = payload[:status])
      { status: status.to_i }
    elsif (error = payload[:exception])
      exception, _message = error
      { status: get_error_status_code(exception) }
    else
      { status: 0 }
    end
  end

  def get_error_status_code(exception)
    status = ActionDispatch::ExceptionWrapper.rescue_responses[exception]
    Rack::Utils.status_code(status)
  end
end

RequestSubscriber.logstash = logstash
RequestSubscriber.attach_to(:action_controller)