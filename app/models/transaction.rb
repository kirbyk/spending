class Transaction < ActiveRecord::Base
  belongs_to :category
  belongs_to :user

  scope :venmo, -> {where(data_source: :venmo)}
  scope :plaid, -> {where(data_source: :plaid)}
end
