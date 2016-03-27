class ElasticsearchJobLogger < ActiveSupport::LogSubscriber
  class << self
    attr_accessor :logstash
  end

  def perform(event)
    payload = event.payload
    job = payload[:job]

    output = LogStash::Event.new
    output[:type] = :job
    output[:timing] = {
      start: event.time,
      end: event.end,
      duration: (event.end - event.time) * 1000
    }
    output[:job] = {
      type: job.class.to_s,
      queue: job.queue_name
    }

    ElasticsearchJobLogger.logstash.info(output.to_json)
  end
end
