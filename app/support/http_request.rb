class HttpRequest
  def self.get(url, opts = {})
    connection(url, opts).get url, {}, opts
  end

  def self.post(url, body, opts = {})
    send_payload(:post, url, body, opts)
  end

  def self.put(url, body, opts = {})
    send_payload(:put, url, body, opts)
  end

  def self.connection(url, opts)
    url = URI.new(url) unless url.is_a? URI
    Faraday.new(url: url) do |faraday|
      faraday.use(ZipkinTracer::FaradayHandler, url.host)
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
      yield(faraday) if block_given?
    end
  end

  def self.send_payload(method, url, body, opts = {})
    resp = connection(url, opts).send(method) do |req|
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
