module ZipkinActiveRecordTracing
  def select_all(*args, &block)
    ZipkinTracer::TraceClient.local_component_span('ActiveRecord') do |ztc|
      ztc.record args[1] if args[1]
      ztc.record_tag('query', args[0]) if args[0]

      super
    end
  end
end

module ZipkinViewRendering
  def render(*args, &block)
    ZipkinTracer::TraceClient.local_component_span('ViewRender') do |ztc|
      ztc.record 'View'
      name = args[0].instance_eval('@virtual_path')
      ztc.record_tag('Name', name) if name
      super
    end
  end
end

if ENV.key? 'ZIPKIN_REPORT_HOST'
  Rails.configuration.after_initialize do
    ActionView::Template.prepend ZipkinViewRendering
    ActiveRecord::ConnectionAdapters::DatabaseStatements.prepend ZipkinActiveRecordTracing
  end
end
