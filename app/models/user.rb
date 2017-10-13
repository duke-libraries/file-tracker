class User < ApplicationRecord

  include UserAdmin

  validates :uid, presence: true, uniqueness: true
  devise :database_authenticatable, :omniauthable, omniauth_providers: [:shibboleth]
  before_create :set_password, unless: :encrypted_password?

  scope :admins, ->{ where(is_admin: true) }

  def self.from_omniauth(auth)
    find_or_create_by!(uid: auth.uid)
  end

  def admin?
    is_admin
  end

  private

  def set_password
    self.password = Devise.friendly_token
  end

end
