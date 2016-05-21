class CertificateBundle < ActiveRecord::Base
  has_and_belongs_to_many :public_keys, autosave: true

  def add(pub)
    public_keys << pub
  end
end