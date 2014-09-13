class AddMfaVerifiedToUser < ActiveRecord::Migration
  def change
    add_column :users, :mfa_verified, :boolean
  end
end
