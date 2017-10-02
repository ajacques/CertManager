class HttpRequest
  def self.get(url, opts = {})
    connection(url, opts).get url, {}, opts
  end

  def self.post(url, body, opts = {})
    resp = connection(url, opts).post do |req|
      req.url url
      req.headers['Accept'] = opts['Accept']
      req.body = body
    end
    resp.body
  end

  def self.connection(url, opts)
    upstream_service_name = opts.delete(:service_name)
    Faraday.new(url: url) do |faraday|
      faraday.use(ZipkinTracer::FaradayHandler, upstream_service_name) if upstream_service_name
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
      yield(faraday) if block_given?
    end
  end
end
