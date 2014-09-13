class CategoryThree < Category
  belongs_to :category_two, foreign_key: 'parent_id'

  def parent
    CategoryTwo.find_by(child_id: parent_id);
  end
end
