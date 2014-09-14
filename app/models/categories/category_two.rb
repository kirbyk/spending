class CategoryTwo < Category
  belongs_to :category_one, foreign_key: 'parent_id'
  has_many   :category_three, foreign_key: 'child_id'

  def parent
    CategoryOne.find_by(child_id: parent_id);
  end
end
