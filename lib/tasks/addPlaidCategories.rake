require 'unirest'
desc 'adds plaid categories into the DB'
task :addPlaidCategories => :environment do
  responses = Unirest.get 'https://tartan.plaid.com/categories'
  responses.body.each do |cat|
    if Category.find_by( plaid_id: cat['_id']).present?
      next
    end
    high = cat['hierarchy']
    if high.length == 1
      c = CategoryOne.create name: high.last, plaid_id: cat['_id']
    elsif high.length == 2
      parent_name = high[0]
      c = CategoryTwo.create plaid_id: cat['_id'], name: high.last,
                             parent_name: parent_name
    elsif high.length == 3
      parent_name = high[1]
      c = CategoryThree.create plaid_id: cat['_id'], name: high.last,
                               parent_name: parent_name
    end
  end

  CategoryTwo.all.each do |cat|
    p = CategoryOne.find_by name: cat.parent_name
    cat.parent_id = p.id
    p.child_id = cat.id
    cat.save
    p.save
  end

  CategoryThree.all.each do |cat|
    p = CategoryTwo.find_by name: cat.parent_name
    cat.parent_id = p.id
    p.child_id = cat.id
    cat.save
    p.save
  end

  Category.all.each do |cat|
    ap cat
  end
end
