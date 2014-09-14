class CategoryOne < Category
  has_many :category_two, foreign_key: 'child_id'

end
