class AddCategoryidToPost < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :category_id, :integer
  end
end
