class RenameColumnUserMfaVerifiedToVerified < ActiveRecord::Migration
  def change
    rename_column :users, :mfa_verified, :verified
  end
end
