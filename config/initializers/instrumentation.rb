module RedisInstrumentation
  class LogSubscriber < ActiveSupport::LogSubscriber
    def self.runtime
      @runtime
    end
    def self.reset_runtime
      @runtime = 0.0
    end
    def query(event)
      return unless logger.debug?

      name = '%s (%.1fms)' % ["Redis Query", event.duration]

      command = event.payload[:command]
      args = event.payload[:args].join(' ')
      LogSubscriber.inc_runtime(event.duration)

      debug "  #{color(name, YELLOW, true)} #{command} #{args}"
    end
    private
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
        messages, runtime = super, payload[:redis_runtime]
        messages << ("Redis: %.1fms" % runtime.to_f) if runtime
        messages
      end
    end
  end
end

RedisInstrumentation::LogSubscriber.attach_to :redis

ActiveSupport.on_load(:action_controller) do
  include RedisInstrumentation::ControllerRuntime
end