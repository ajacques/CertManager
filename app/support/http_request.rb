require 'opencensus/trace/integrations/rack_middleware'
require 'opencensus/trace/integrations/faraday_middleware'

class HttpRequest
  def self.get(url, opts = {})
    opts[:span_name] = opts[:service_name] if opts.key? :service_name
    connection(url).get url, {}, opts
  end

  def self.post(url, body, opts = {})
    opts[:span_name] = opts[:service_name] if opts.key? :service_name
    send_payload(:post, url, body, opts)
  end

  def self.put(url, body, opts = {})
    opts[:span_name] = opts[:service_name] if opts.key? :service_name
    send_payload(:put, url, body, opts)
  end

  def self.connection(url)
    url = URI(url) unless url.is_a? URI
    Faraday.new(url: url) do |faraday|
      faraday.use Faraday::Response::RaiseError
      faraday.use OpenCensus::Trace::Integrations::FaradayMiddleware, span_name: url.host
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
      yield(faraday) if block_given?
    end
  end

  def self.send_payload(method, url, body, opts = {})
    resp = connection(url).send(method) do |req|
      req.url url
      req.headers['Accept'] = opts['Accept']
      req.headers['Authorization'] = opts[:auth] if opts.key? :auth
      req.headers['Content-Type'] = opts[:content_type] if opts.key? :content_type
      req.body = body
      Rails.logger.info "Sending HTTP #{method} #{url}"
    end
    resp.body
  end
end
