class Service < ActiveRecord::Base
  belongs_to :certificate

  def deploy
    chain = certificate.full_chain(true)
    salt = SaltClient.new
    salt.delete_file(self.cert_path)
    salt.append_file(self.cert_path, chain)
    salt.shell_execute(self.after_rotate)
  end
end
