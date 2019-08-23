module RequestLogging
  extend ActiveSupport::Concern

  included do
    append_before_action :annotate_logs
  end

  protected

  def annotate_logs
    RequestStore.store[:request] = request
    RequestStore.store[:response] = response
    web_trace = OpenCensus::Trace.span_context.trace_id
    web_span = SecureRandom.hex(8)
    trace = "00-#{web_trace}-#{web_span}-01"
    RequestStore.store[:web_trace] = trace
    context = OpenCensus::Trace.span_context
    context
      .instance_variable_get(:@trace_data)
      .span_map[context.span_id]
      .put_link(web_trace, web_span, OpenCensus::Trace::SpanBuilder::PARENT_LINKED_SPAN)
  end
end
