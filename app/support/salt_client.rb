class SaltClient
  def initialize
    @user = CertManager::Configuration.salt_stack['user']
    @pass = CertManager::Configuration.salt_stack['pass']
    @eauth = CertManager::Configuration.salt_stack['eauth']
    @host = CertManager::Configuration.salt_stack['host']
  end

  def login
    uri = URI("#{@host}/login")
    body = {
      username: @user,
      password: @pass,
      eauth: @eauth
    }
    Net::HTTP.start(uri.host, uri.port) do |http|
      req = Net::HTTP::Post.new(uri.request_uri)
      req['Accept'] = 'application/x-yaml'
      req.set_form_data(body)
      res = http.request(req) # Check HTTP Status code here
      @auth_token = res['X-Auth-Token']
    end
  end

  def get_hash(target, file)
    execute(target, 'file.get_hash', file)
  end

  def delete_file(target, file)
    execute(target, 'file.remove', file)
  end

  def create_file(target, file)
    execute(target, 'file.touch', file)
  end

  def file_exists?(target, file)
    execute(target, 'file.access', file, 'f')
  end

  def truncate_file(target, file)
    execute(target, 'file.truncate', file, 0)
  end

  def shell_execute(target, cmd)
    execute(target, 'cmd.run', cmd)
  end

  def append_file(target, file, body)
    execute(target, 'file.append', file, *body.split(/\r?\n/))
  end

  def stat_file(target, file)
    Hash[execute(target, 'file.lstat', file).map {|key, value|
      val = {
        created: Time.at(value['st_ctime']),
        accessed: Time.at(value['st_atime']),
        modified: Time.at(value['st_mtime']),
        size: value['st_size'],
        uid: value['st_uid'],
        gid: value['st_gid'],
        perms: value['st_mode']
      } if value.key?('st_ctime')
      [key, val]
    }]
  end

  def get_minions(filter = '*')
    uri = URI("#{@host}/minions/#{filter}")
    Net::HTTP.start(uri.host, uri.port) do |http|
      req = Net::HTTP::Get.new(uri.request_uri)
      req['Accept'] = 'application/x-yaml'
      req['X-Auth-Token'] = @auth_token
      YAML.load(http.request(req).body)
    end
  end

  def execute(target, cmd, *args)
    uri = URI("#{@host}/run")
    body = {
      username: @user,
      password: @pass,
      eauth: @eauth,
      fun: cmd,
      client: 'local',
      tgt: target,
      arg: args
    }
    Net::HTTP.start(uri.host, uri.port) do |http|
      req = Net::HTTP::Post.new(uri.request_uri)
      req['Accept'] = 'application/x-yaml'
      # req['X-Auth-Token'] = @auth_token
      req.set_form_data(body)
      map_response(YAML.load(http.request(req).body))
    end
  end

  def map_response(resp)
    raise "Salt returned error: #{resp.inspect}" if resp.key?('status')
    Hash[*resp['return'].map(&:to_a).flatten]
  end
end
