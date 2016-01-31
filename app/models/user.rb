require 'securerandom'

class User < ActiveRecord::Base
  attr_accessor :password, :password_confirmation, :confirmation_token_confirmation
  attr_reader :reset_password_token_confirmation
  validates :first_name, :last_name, presence: true
  validates :email, email: true, uniqueness: true
  validates :password, length: { within: 6..128 }, confirmation: true, allow_nil: true
  validates :confirmation_token, confirmation: true
  validates :reset_password_token, confirmation: true
  before_save :update_password
  belongs_to :lets_encrypt_key, class_name: 'PrivateKey'

  def password_matches?(pwd)
    password_hash == User.hash_password(pwd, password_salt)
  end

  def create_confirm_token
    self.confirmation_token = SecureRandom.urlsafe_base64(32)
    self.confirmation_sent_at = Time.now
  end

  def create_reset_token
    self.reset_password_token = SecureRandom.urlsafe_base64 32
    self.reset_password_sent_at = Time.now
  end

  def randomize_password
    self.password = SecureRandom.urlsafe_base64(32)
  end

  def to_s
    "#{first_name} #{last_name}"
  end

  def email_addr
    "#{self} <#{email}>"
  end

  def validate_reset_token!(token)
    fail 'Invalid token' unless reset_password_token == token
    fail 'Expired token' unless Time.now < (reset_password_sent_at + 6.hours)
  end

  def self.authenticate!(username, password)
    user = find_by_email(username)
    if user.present? && user.password_matches?(password) && user.can_login?
      user.last_sign_in_at = Time.now
      user.save!
      user
    end
  end

  # Returns true if this user can perform {action} on {target}
  def can?(_action, _target)
    true
  end

  def reset_token(name)
    send("#{name}_token=".to_sym, nil)
    send("#{name}_sent_at=".to_sym, nil)
  end

  def reset_token!(name)
    reset_token name
    save!
  end

  def self.hash_password(pwd, salt)
    Digest::SHA256.digest("#{pwd}#{salt}")
  end

  private

  def update_password
    if password
      self.password_salt = SecureRandom.random_bytes(32)
      self.password_hash = User.hash_password(password, password_salt)
    end
  end
end
