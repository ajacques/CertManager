require 'securerandom'

class User < ActiveRecord::Base
  attr_accessor :password
  validates :email_address, :password, presence: true
  validates :email_address, uniqueness: true
  validates :password, length: { within: 6..128}
  validates :password, confirmation: true
  before_save :update_password

  def self.authenticate(username, password)
    user = where(email_address: username).first
    return nil if user.nil?
    user if user.password_hash == User.hash_password(password, user.password_salt)
  end

  private
  def update_password
    self.password_salt = SecureRandom.random_bytes(32)
    self.password_hash = User.hash_password(password, self.password_salt) if self.password
  end
  def self.hash_password(pwd, salt)
    string = "#{pwd}#{salt}"
    Digest::SHA256.digest(string)
  end
end