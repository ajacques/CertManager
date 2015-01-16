puts 'SaltClient'

class SaltClient
  def initialize
    @user = CertManager::Configuration.salt_stack['user']
    @pass = CertManager::Configuration.salt_stack['pass']
    @eauth = CertManager::Configuration.salt_stack['eauth']
    @host = CertManager::Configuration.salt_stack['host']
  end
  def delete_file(file)
    logger.info execute('file.remove', file)
  end
  def shell_execute(cmd)
    logger.info execute('cmd.run', cmd)
  end
  def append_file(file, body)
    logger.info execute('file.append',file, body)
  end
  def execute(cmd, *args)
    uri = URI("#{@host}/run")
    body = {
      username: @user,
      password: @pass,
      eauth: @eauth,
      client: 'local',
      tgt: '*',
      fun: cmd,
      arg: args
    }
    Net::HTTP.start(uri.host, uri.port) do |http|
      req = Net::HTTP::Post.new(uri.request_uri)
      req['Accept'] = 'application/x-yaml'
      req.set_form_data(body)
      map_response(YAML.load(http.request(req).body))
    end
  end
  def map_response(resp)
    raise "Salt returned error" if resp.has_key?('status')
    resp['return']
  end
end