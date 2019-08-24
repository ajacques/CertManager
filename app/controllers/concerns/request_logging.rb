module RequestLogging
  extend ActiveSupport::Concern

  included do
    append_before_action :annotate_logs
  end

  protected

  def annotate_logs
    RequestStore.store[:request] = request
    RequestStore.store[:response] = response
    context = OpenCensus::Trace.span_context
    web_trace = context.trace_id
    web_span = SecureRandom.hex(8)
    trace = "00-#{context.trace_id}-#{web_span}-#{context.trace_options.to_s.rjust(2, '0')}"
    RequestStore.store[:web_trace] = trace
    context
      .instance_variable_get(:@trace_data)
      .span_map[context.span_id]
      .put_link(web_trace, web_span, OpenCensus::Trace::SpanBuilder::PARENT_LINKED_SPAN)
  end
end
