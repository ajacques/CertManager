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
      transport: :websocket,
      endpoint: iot_url
    }
    render json: response
  end

  private

  def iot_url
    # TODO: All of this is temporary code
    # Pull from the credentials provider
    access_key = ENV['AWS_ACCESS_KEY']
    secret_key = ENV['AWS_SECRET_KEY']
    createEndpoint('a1bqd389926wie.iot.us-east-1.amazonaws.com', 'us-east-1', access_key, secret_key)
  end

  def createEndpoint(endpoint, regionName, accessKey, secretKey)
    time = Time.now.utc
    dateStamp = time.strftime("%Y%m%d")
    amzdate = time.strftime("%Y%m%dT%H%M%SZ")
    service = 'iotdevicegateway'
    algorithm = 'AWS4-HMAC-SHA256'
    method = 'GET'
    canonicalUri = '/mqtt'

    credentialScope = dateStamp + '/' + regionName + '/' + service + '/' + 'aws4_request'
    canonicalQuerystring = 'X-Amz-Algorithm=AWS4-HMAC-SHA256'
    canonicalQuerystring << '&X-Amz-Credential=' + encodeURIComponent(accessKey + '/' + credentialScope)
    canonicalQuerystring << '&X-Amz-Date=' + amzdate
    canonicalQuerystring << '&X-Amz-SignedHeaders=host'

    canonicalHeaders = 'host:' + endpoint + "\n"
    payloadHash = OpenSSL::Digest.hexdigest('sha256', '')
    canonicalRequest = method + "\n" + canonicalUri + "\n" + canonicalQuerystring + "\n" + canonicalHeaders + "\nhost\n" + payloadHash

    stringToSign = algorithm + "\n" +  amzdate + "\n" +  credentialScope + "\n" +  OpenSSL::Digest.hexdigest('sha256', canonicalRequest)
    signingKey = signature_key(secretKey, dateStamp, regionName, service)
    signature = OpenSSL::HMAC.hexdigest('sha256', signingKey, stringToSign)

    canonicalQuerystring << '&X-Amz-Signature=' + signature
    return 'wss://' + endpoint + canonicalUri + '?' + canonicalQuerystring
  end

  def encodeURIComponent(str)
    URI.escape(str, /[^-_.!~*'()a-zA-Z\d]/u)
  end

  def signature_key(key, date_stamp, region_name, service_name)
    date    = OpenSSL::HMAC.digest('sha256', 'AWS4' + key, date_stamp)
    region  = OpenSSL::HMAC.digest('sha256', date, region_name)
    service = OpenSSL::HMAC.digest('sha256', region, service_name)
    OpenSSL::HMAC.digest('sha256', service, 'aws4_request')
  end
end
