# This file is used by Rack-based servers to start the application.

require ::File.expand_path('config/environment', __dir__)
run Rails.application

if ENV.key? 'ZIPKIN_REPORT_HOST'
  sample_rate = ENV['ZIPKIN_SAMPLE_RATE'].to_f || 0.1
  puts "[INFO] Zipkin reporting enabled - Sample rate: #{sample_rate * 100}%"
  use(
    ZipkinTracer::RackHandler,
    service_name: ENV['ZIPKIN_SERVICE_NAME'] || 'CertManager',
    service_port: 443,
    sample_rate: sample_rate,
    json_api_host: ENV['ZIPKIN_REPORT_HOST'],
    log_tracing: true
  )
end
