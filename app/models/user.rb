class User < ActiveRecord::Base
  after_commit :parse_venmo, on: :create

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:venmo]

  has_many :tags
  has_many :transactions

  def self.from_omniauth(auth)
    where(provider: auth.provider, venmo_uid: auth.uid).first_or_create! do |user|
      user.venmo_access_token = auth.credentials.token
      user.password = Devise.friendly_token[0,20]
    end
  end

  def email_required?
    provider.blank?
  end

  private
  def parse_venmo
    transactions = nil
    loop do
      if transactions.present?
        next_page = transactions['pagination']['next']
        transactions = Unirest.get(next_page).body
      else
        transactions = get_venmo_transactions 200
      end
      transactions['data'].each do |t|
        tt = Transaction.find_by(venmo_id: t['id'])
        if tt.present?
          next
        end
        target_type = nil
        target      = nil
        if t['target']['phone'].present?
          target_type = :phone
          target      = t['target']['phone']
        elsif t['target']['email'].present?
          target_type = :email
          target      = t['target']['email']
        else
          target_type = :user
          target      = t['target']['user']['id']
        end
        target = t['target']['phone'] ||
                 t['target']['email'] ||
                 t['target']['user']['id']
        Transaction.create user_id:         id,
                           data_source:     :venmo,
                           venmo_id:        t['id'],
                           note:            t['note'],
                           amount:          t['amount'] * 100,
                           audience:        t['audience'],
                           action:          t['action'],
                           date_completed:  t['date_completed'],
                           actor_id:        t['actor']['id'],
                           target_type:     target_type,
                           target_id:       target
      end
      break if transactions['pagination']['next'].nil?
    end
  end

  def get_venmo_transactions limit=nil, after=nil, before=nil
    if venmo_access_token.nil?
      raise 'Venmo access token is nil after account creation'
    end
    base_url = "https://api.venmo.com/v1/payments?access_token=#{venmo_access_token}"
    if limit.present?
      base_url += "&limit=#{limit}"
    end
    if before.present?
      base_url += "&before=#{before}"
    end
    if after.present?
      base_url += "&after=#{after}"
    end

    Unirest.get(base_url).body
  end

  handle_asynchronously :parse_venmo
end
