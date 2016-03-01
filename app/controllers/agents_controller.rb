class AgentsController < ActionController::Base
  def register
    agent = Agent.find_by_registration_token(params[:token])
    response = {
      access_token: SecureRandom.hex
    }
    render json: response
  end

  def bootstrap
    agent = Agent.find_by_access_token(params[:token])
    response = {
      transport: :http_poll,
      endpoint: agent_stream_url(host: 'certmgr.devvm', port: 80)
    }
    render json: response
  end

  def stream
    response = {
      continuation: {
        abort: false,
        refresh: 60
      },
      operations: []
    }
    render json: response
  end

  private

  def iot_url
    # TODO: All of this is temporary code
    # Pull from the credentials provider
    access_key = ENV['AWS_ACCESS_KEY']
    secret_key = ENV['AWS_SECRET_KEY']
    create_endpoint('a1bqd389926wie.iot.us-east-1.amazonaws.com', 'us-east-1', access_key, secret_key)
  end

  def create_endpoint(endpoint, region_name, access_key, secret_key)
    time = Time.now.utc
    data_stamp = time.strftime('%Y%m%d')
    amzdate = time.strftime('%Y%m%dT%H%M%SZ')
    service = 'iotdevicegateway'
    algorithm = 'AWS4-HMAC-SHA256'
    method = 'GET'
    canonical_uri = '/mqtt'

    credential_scope = data_stamp + '/' + region_name + '/' + service + '/' + 'aws4_request'
    canonical_querystring = 'X-Amz-Algorithm=AWS4-HMAC-SHA256'
    canonical_querystring << '&X-Amz-Credential=' + encode_uri_component(access_key + '/' + credential_scope)
    canonical_querystring << '&X-Amz-Date=' + amzdate
    canonical_querystring << '&X-Amz-SignedHeaders=host'

    canonical_headers = 'host:' + endpoint + "\n"
    payload_hash = OpenSSL::Digest.hexdigest('sha256', '')
    canonical_request = "#{method}\n#{canonical_uri}\n#{canonical_querystring}\n#{canonical_headers}\nhost\n#{payload_hash}"

    string_to_sign = algorithm + "\n" + amzdate + "\n" +  credential_scope + "\n" +  OpenSSL::Digest.hexdigest('sha256', canonical_request)
    signing_key = signature_key(secret_key, data_stamp, region_name, service)
    signature = OpenSSL::HMAC.hexdigest('sha256', signing_key, string_to_sign)

    canonical_querystring << '&X-Amz-Signature=' + signature
    'wss://' + endpoint + canonical_uri + '?' + canonical_querystring
  end

  def encode_uri_component(str)
    URI.escape(str, /[^-_.!~*'()a-zA-Z\d]/u)
  end

  def signature_key(key, date_stamp, region_name, service_name)
    date    = OpenSSL::HMAC.digest('sha256', 'AWS4' + key, date_stamp)
    region  = OpenSSL::HMAC.digest('sha256', date, region_name)
    service = OpenSSL::HMAC.digest('sha256', region, service_name)
    OpenSSL::HMAC.digest('sha256', service, 'aws4_request')
  end
end
