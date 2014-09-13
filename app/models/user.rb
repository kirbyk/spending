class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:venmo]

  has_many :tags

  def self.from_omniauth(auth)
    where(provider: auth.provider, venmo_uid: auth.uid).first_or_create! do |user|
      user.venmo_access_token = auth.credentials.token
      user.password = Devise.friendly_token[0,20]
    end
  end

  def email_required?
    provider.blank?
  end
end
