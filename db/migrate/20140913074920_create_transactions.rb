class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :user_id
      t.string :data_source
      t.string :note
      t.integer :amount
      t.string :audience
      t.string :action
      t.string :venmo_id
      t.datetime :date_completed
      t.string :actor_id
      t.string :target_id

      t.timestamps
    end
  end
end
