class User < ActiveRecord::Base
  validates :user_name, :password_digest, :session_token, presence: true
  validates :user_name, :session_token, uniqueness: true
  after_initialize :ensure_session_token

  def self.find_by_credentials(user_name, password)
    user = User.find_by(user_name: user_name)
    return user if user && user.is_password?(password)
    nil
  end

  def password=(password)
    self.password_digest = BCrypt::Password.create(password)
    self.save
  end

  def reset_session_token!
    self.session_token = generate_token
    self.save
  end

  def generate_token
    SecureRandom.urlsafe_base64(128)
  end

  def is_password?(password)
    pass_check = BCrypt::Password.create(password)
    pass_check == self.password_digest
  end

  private
  def ensure_session_token
    self.session_token ||= generate_token
    self.save
  end
end