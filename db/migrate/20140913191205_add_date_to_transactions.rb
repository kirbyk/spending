class AddDateToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :date, :string
  end
end
