class AddParentNameToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :parent_name, :string
  end
end
