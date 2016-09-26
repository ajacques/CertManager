class ElasticsearchHttpRequestLogger < ActiveSupport::LogSubscriber
  class << self
    attr_accessor :logstash
  end

  def process_action(event)
    data = event.payload
    output = LogStash::Event.new
    actor = RequestStore.store[:actor]
    response = RequestStore.store[:response]
    output.type = 'http_request'
    output[:response] = extract_status(data)
    output[:timing] = {
      total: event.duration,
      view: data[:view_runtime],
      db: data[:db_runtime],
      redis: data[:redis_runtime]
    }
    if response
      output[:response][:redirect_location] = response.headers['Location'] if response.headers.key? 'Location'
      output[:response][:content_type] = response.content_type
    end
    output[:routing] = {
      controller: data[:controller],
      action: data[:action],
      resource: "#{data[:controller]}##{data[:action]}"
    }
    append_request(output, data)

    if actor.is_a? User
      output[:user] = {
        id: actor.id,
        username: actor.email
      }
    end
    ElasticsearchHttpRequestLogger.logstash.info(output.to_json)
  end

  def append_request(output, data)
    request = RequestStore.store[:request]
    return unless request
    output[:request] = {
      method: data[:method],
      path: URI(data[:path]).path,
      format: data[:format],
      proxy_ip: request.remote_ip,
      client_ip: request.env['HTTP_X_FORWARDED_FOR']
    }
    mg = {
      id: request.env['action_dispatch.request_id'],
      user_agent: request.env['HTTP_USER_AGENT']
    }
    output[:request][:requested_with] = request.headers['X-Requested-With'] if request.headers.key? 'X-Requested-With'
    output[:request].merge!(mg)
  end

  def extract_status(payload)
    if (status = payload[:status])
      { status: status.to_i }
    elsif (error = payload[:exception])
      exception, message = error
      {
        status: get_error_status_code(exception),
        error: {
          class: exception,
          message: message
        }
      }
    else
      { status: 0 }
    end
  end

  def get_error_status_code(exception)
    status = ActionDispatch::ExceptionWrapper.rescue_responses[exception]
    Rack::Utils.status_code(status)
  end
end
