module ZipkinViewRendering
  def render(view, *args, &block)
    ZipkinTracer::TraceClient.local_component_span(virtual_path) do |ztc|
      super
    end
  end
end

module ZipkinActionController
  def send_action(*args, &block)
    fully_qualified = "#{self.class.name}\##{args[0]}"
    ZipkinTracer::TraceClient.local_component_span(fully_qualified) do |ztc|
      super
    end
  end
end

module ZipkinReactRender
  def react_component(name, props = {}, options = {}, &block)
    ZipkinTracer::TraceClient.local_component_span("React:#{name}") do |ztc|
      super
    end
  end
end

if ENV.key? 'ZIPKIN_REPORT_HOST'
  Rails.configuration.after_initialize do
    ActiveSupport.on_load(:action_view, run_once: true) do
      ActionView::Template.prepend ZipkinViewRendering
    end
    ActiveSupport.on_load(:action_controller, run_once: true) do
      prepend ZipkinActionController
    end
    React::Rails::ComponentMount.prepend ZipkinReactRender
  end
end
