class User < ApplicationRecord

  validates :uid, presence: true, uniqueness: true
  devise :database_authenticatable, :omniauthable, omniauth_providers: [:shibboleth]
  before_create :set_generated_password, if: "password.blank?"

  def self.from_omniauth(auth)
    find_or_create_by!(uid: auth.uid)
  end

  private

  def set_generated_password
    self.password = Devise.friendly_token
  end

end
