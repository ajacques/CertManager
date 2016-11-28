module RedisInstrumentation
  class LogSubscriber < ActiveSupport::LogSubscriber
    class << self
      attr_reader :runtime
    end

    def self.reset_runtime
      @runtime = nil
    end

    def query(event)
      return unless logger.debug?

      name = 'Redis Query (%.1fms)'. % event.duration

      command = event.payload[:command]
      args = event.payload[:args]
      LogSubscriber.inc_runtime(event.duration)

      reduced = args.map do |arg|
        if arg.to_s.ascii_only?
          arg
        else
          '[Binary]'
        end
      end.join(' ')

      debug "  #{color(name, YELLOW, true)} #{command} #{reduced}"
    end

    def self.inc_runtime(inc)
      @runtime = (@runtime || 0.0) + inc
    end
  end
  module ControllerRuntime
    extend ActiveSupport::Concern

    protected

    def append_info_to_payload(payload)
      super
      payload[:redis_runtime] = RedisInstrumentation::LogSubscriber.runtime
      LogSubscriber.reset_runtime
    end

    module ClassMethods
      def log_process_action(payload)
        messages = super
        runtime = payload[:redis_runtime]
        messages << 'Redis: %.1fms' % runtime if runtime
        messages
      end
    end
  end
end

RedisInstrumentation::LogSubscriber.attach_to :redis

ActiveSupport.on_load(:action_controller) do
  include RedisInstrumentation::ControllerRuntime
end
