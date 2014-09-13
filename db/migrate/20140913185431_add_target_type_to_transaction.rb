class AddTargetTypeToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :target_type, :string
  end
end
