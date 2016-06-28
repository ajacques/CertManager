class Service::Salt < Service
  service_prop :cert_path, :after_rotate, :node_group

  def deploy
    chain = certificate.full_chain(true)
    salt = SaltClient.new

    salt.stat_file(node_group, cert_path).each do |minion, stat|
      if stat
        Rails.logger << "#{minion}: File exists #{cert_path}"
        handle_result(salt.truncate_file(node_group, cert_path), 'truncate file')
      else
        Rails.logger << "#{minion}: Creating file #{cert_path}"
        salt.create_file(minion, cert_path)
      end
    end
    handle_result(salt.append_file(node_group, cert_path, chain), 'append_file')
    handle_result(salt.shell_execute(node_group, after_rotate), 'execute script')

    self.last_deployed = Time.now
  end

  def node_status
    rkey = "SERVICE_#{id}_NODESTATUS"
    redis = CertManager::Configuration.redis_client
    redis.hgetall(rkey).map { |key, value|
      json = JSON.parse value
      node = Node.new key
      node.hash = json['hash']
      node.valid = json['valid']
      node.exists = json['exists']
      node.updated_at = Time.parse(json['update'])
      node
    }
  end

  private

  def handle_result(input, msg)
    input.each do |key, val|
      msg = (if val
               "Successfully #{msg} #{val}"
             else
               "Failed to #{msg} #{val}"
             end)
      Rails.logger << "#{key}: #{msg}"
    end
  end
end
