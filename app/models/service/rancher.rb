class Service::Rancher < Service
  service_prop :service_endpoint, :bearer_token
  service_prop :cluster_id, :project_id, :namespace, :rancher_cert_id

  def deploy
    HttpRequest.put(
      update_url, update_payload.to_json,
      content_type: 'application/json',
      auth: "Bearer #{bearer_token}",
      'Accept' => 'application/json'
    )
  rescue Faraday::ClientError => e
    body = JSON.parse(e.response[:body])
    message = "Rancher returned: #{body['message']}"
    ServiceDeployFailed.raise_faraday message, e
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
      key: certificate.private_key.to_pem,
      annotations: {
        'certs.technowizardry.net/service' => id
      }
    }
  end

  def cert_chain
    chain = certificate.chain.reverse.map do |cert|
      cert.public_key.to_pem
    end
    chain.join("\n")
  end

  def cert_uri_part
    if namespace.empty?
      'certificates'
    else
      'namespacedCertificates'
    end
  end

  def update_url
    uri = URI(service_endpoint)
    uri.path = "#{uri.path}/project/#{cluster_id}:#{project_id}/#{cert_uri_part}/#{rancher_cert_id}"
    uri
  end
end
