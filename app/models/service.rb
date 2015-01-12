class Service < ActiveRecord::Base
  belongs_to :certificate

  def deploy
    chain = certificate.full_chain(true)
    @user = CertManager::Configuration.salt_stack['user']
    @pass = CertManager::Configuration.salt_stack['pass']
    @eauth = CertManager::Configuration.salt_stack['eauth']
    @host = CertManager::Configuration.salt_stack['host']
    [
      delete_file(self.cert_path),
      append_file(self.cert_path, chain),
      shell_execute(self.after_rotate)
    ]
  end

  private
  def delete_file(file)
    execute('file.remove', file)
  end
  def shell_execute(cmd)
    execute('cmd.run', cmd)
  end
  def append_file(file, body)
    execute('file.append',file, body)
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
      YAML.load(http.request(req).body)
    end
  end
end
