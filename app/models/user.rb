require 'securerandom'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :registerable, :recoverable, :rememberable, :trackable, :validatable
  attr_accessor :password
  validates :email, :password, presence: true
  validates :email, uniqueness: true
  validates :password, length: { within: 6..128 }
  validates :password, confirmation: true
  before_save :update_password

  def password_matches?(pwd)
    password_hash == User.hash_password(pwd, password_salt)
  end
  def create_confirm_token
    confirmation_token = SecureRandom.urlsafe_base64(32)
    confirmation_sent_at = Time.now
  end
  def to_s
    "#{first_name} #{last_name}"
  end
  def self.authenticate(username, password)
    user = find_by_email(username)
    return nil  if user.nil?
    return user if user.password_matches?(password) and user.can_login?
  end

  private
  def update_password
    if self.password
      self.password_salt = SecureRandom.random_bytes(32)
      self.password_hash = User.hash_password(password, self.password_salt)
    end
  end
  def self.hash_password(pwd, salt)
    Digest::SHA256.digest("#{pwd}#{salt}")
  end
end