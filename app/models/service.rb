class Service < ActiveRecord::Base
  belongs_to :certificate

  def deployable?
    certificate.signed?
  end
  def deploy
    chain = certificate.full_chain(true)
    salt = SaltClient.new

    salt.stat_file(self.node_group, self.cert_path).each do |minion, stat|
      if stat
        Rails.logger << "#{minion}: File exists #{self.cert_path}"
        handle_result(salt.truncate_file(self.node_group, self.cert_path), 'truncate file')
      else
        Rails.logger << "#{minion}: Creating file #{self.cert_path}"
        salt.create_file(minion, self.cert_path)
      end
    end
    handle_result(salt.append_file(self.node_group, self.cert_path, chain), 'append_file')
    handle_result(salt.shell_execute(self.node_group, self.after_rotate), 'execute script')

    last_deployed = Time.now
  end

  private
  def handle_result(input, msg)
    input.each do |key, val|
      msg = (if val
        "Successfully #{msg} #{val}"
      else
        "Failed to #{msg} #{val}"
      end)
      Rails.logger << ("#{key}: #{msg}")
    end
  end
end
