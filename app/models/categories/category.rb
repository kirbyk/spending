class Category < ActiveRecord::Base
  has_many :transactions

  def generalize
    if self.parent_id
      parent = Category.find(parent_id)
    else
      return self.name
    end

    parent.generalize
  end
end
