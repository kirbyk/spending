class ChangeUidColumnToVenmoUid < ActiveRecord::Migration
  def change
    rename_column :users, :uid, :venmo_uid
  end
end
