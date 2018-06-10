class Service::Rancher < Service
  service_prop :service_endpoint, :bearer_token
  service_prop :cluster_id, :project_id, :namespace, :rancher_cert_id

  def update_external
    HttpRequest.post(update_url, update_payload, auth: bearer_token, 'Accept' => 'application/json')
    self.last_deployed = Time.now.utc
  end

  def push_deployable?
    true
  end

  def ui_link
    uri = URI(service_endpoint)
    uri.path = "/p/#{cluster_id}:#{project_id}/certificates/#{rancher_cert_id}"
    uri
  end

  private

  def update_payload
    {
      certs: cert_chain,
      key: certificate.private_key.to_pem
    }
  end

  def cert_chain
    certificate.chain.map do |cert|
      cert.public_key.to_pem
    end
  end

  def update_url
    uri = URI(service_endpoint)
    uri.path = "#{uri.path}/project/#{cluster_id}:#{project_id}/namespacedCertificates/#{rancher_cert_id}"
    uri
  end
end