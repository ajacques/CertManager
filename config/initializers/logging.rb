config = Rails.application.config

Rails.logger = ActiveSupport::TaggedLogging.new LogStashLogger.new type: :udp, host: 'logstash', port: 5228
config.log_level = :debug
config.lograge.enabled = true

class LogRageFormatter
  def call(data)
    load_dependencies
    event = LogStash::Event.new
    event.type = 'http_request'
    event[:response] = {
      status: data[:status]
    }
    event[:timing] = {
      total: data[:duration],
      view: data[:view],
      db: data[:db]
    }
    event[:request] = {
      method: data[:method],
      path: data[:path],
      format: data[:format]
    }
    event[:routing] = {
      controller: data[:controller],
      action: data[:action]
    }

    event.to_json
  end

  def load_dependencies
    require 'logstash-event'
  rescue LoadError
    puts 'You need to install the logstash-event gem to use the logstash output.'
    raise
  end
end

config.lograge.formatter = LogRageFormatter.new

LogStashLogger.configure do |config|
  config.customize_event do |event|
    if event[:request]
      request = RequestStore.store[:request]
      actor = RequestStore.store[:actor]
      if request
        event[:request].merge!({
          id: request.env['action_dispatch.request_id'],
          user_agent: request.env['HTTP_USER_AGENT']
        })
      end
      if actor.is_a? User
        event[:user] = {
          id: actor.id,
          username: actor.email
        }
      end
    end
  end
end
