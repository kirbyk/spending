class ChangeAccessTokenColumnToVenmoAccessToken < ActiveRecord::Migration
  def change
    rename_column :users, :access_token, :venmo_access_token
  end
end
