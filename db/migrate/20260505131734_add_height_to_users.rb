class AddHeightToUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :diets, :height, :float
    add_column :users, :height, :float
  end
end
