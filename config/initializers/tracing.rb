class CompositeSampler
  SAMPLERS = OpenCensus::Trace::Samplers
  NEVER = SAMPLERS::NeverSample.new
  HIGH_RATE = SAMPLERS::Probability.new 0.0001

  CUSTOM_SAMPLERS = {
    '/ping' => NEVER,
    '/agents/sync' => HIGH_RATE,
    '/agents/report' => HIGH_RATE
  }.freeze

  def initialize
    probability = ENV['OPENCENSUS_SAMPLE_RATE'].to_f / 100
    @probability_sampler = OpenCensus::Trace::Samplers::Probability.new probability
  end

  def call(opts = {})
    request_url = RequestStore.store[:request_url]
    if CUSTOM_SAMPLERS.key? request_url
      CUSTOM_SAMPLERS[request_url].call(opts)
    else
      @probability_sampler.call(opts)
    end
  end
end

class CensusExporter < OpenCensus::Trace::Exporters::Logger
  def initialize(report_host:)
    @report_host = report_host
  end

  def export(spans)
    remap = spans.map { |span| format_span(span) }
    data = {
      node: {
        identifier: {
        },
        libraryInfo: {
          language: 9
        },
        serviceInfo: {
          name: 'CertManager'
        }
      },
      spans: remap
    }
    Faraday.post(@report_host) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = data.to_json
    end
    nil
  end

  private

  def format_id(id)
    Base64.strict_encode64([id].pack('H*'))
  end

  def format_span(span)
    {
      name: format_value(span.name),
      kind: span.kind,
      traceId: format_id(span.trace_id),
      spanId: format_id(span.span_id),
      parentSpanId: format_id(span.parent_span_id),
      startTime: span.start_time,
      endTime: span.end_time,
      attributes: {
        attributeMap: format_attributes(span.attributes)
      },
      links: {
        link: span.links.map { |link| format_link(link) }
      },
      status: format_status(span.status),
      sameProcessAsParentSpan: span.same_process_as_parent_span,
      traceState: {}
    }
  end

  def format_attributes(attrs)
    result = {}
    attrs.each do |k, v|
      result[k] = format_nested_value v
    end
    result
  end

  def format_nested_value(value)
    inner = format_value(value)
    case value
    when String, OpenCensus::Trace::TruncatableString
      {
        string_value: inner
      }
    else
      {
        string_value: format_value(value.to_s)
      }
    end
  end

  def format_value(value)
    case value
    when String, Integer, true, false
      {
        value: value
      }
    when OpenCensus::Trace::TruncatableString
      if value.truncated_byte_count.zero?
        { value: value.value }
      else
        {
          value: value.value,
          truncated_byte_count: value.truncated_byte_count
        }
      end
    else
      { value: value.to_s }
    end
  end
end

class RequestMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    RequestStore.store[:request_url] = env['REQUEST_PATH']
    @app.call(env)
  end
end

enabled = ENV.key? 'OPENCENSUS_INTERNAL_REPORT_URL'
Rails.configuration.tracing_enabled = enabled

OpenCensus::Trace.configure do |c|
  if enabled
    Rails.configuration.trace_endpoint = ENV['OPENCENSUS_REPORT_URL']
    c.default_sampler = CompositeSampler.new
  else
    c.default_sampler = OpenCensus::Trace::Samplers::NeverSample.new
  end
  c.exporter = CensusExporter.new report_host: ENV['OPENCENSUS_INTERNAL_REPORT_URL']
end

Rails.configuration.middleware.insert_before OpenCensus::Trace::Integrations::RackMiddleware, RequestMiddleware
