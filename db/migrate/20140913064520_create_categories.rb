class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :type

      t.string  :plaid_id
      t.string  :name
      t.integer :parent_id
      t.integer :child_id

      t.timestamps
    end
  end
end
