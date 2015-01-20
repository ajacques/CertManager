class Service < ActiveRecord::Base
  belongs_to :certificate

  def deployable?
    certificate.signed?
  end
  def deploy
    chain = certificate.full_chain(true)
    salt = SaltClient.new

    handle_result(salt.delete_file(self.cert_path), 'delete file')
    handle_result(salt.append_file(self.cert_path, chain), 'append_file')
    handle_result(salt.shell_execute(self.after_rotate), 'execute script')
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
