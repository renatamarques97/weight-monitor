class AddMacrosToMeals < ActiveRecord::Migration[8.0]
  def change
    add_column :meals, :calories, :float
    add_column :meals, :protein, :float
    add_column :meals, :carbs, :float
    add_column :meals, :fat, :float
    add_column :meals, :food_name, :string
    add_column :meals, :fatsecret_food_id, :string
    add_column :meals, :metric_serving_unit, :string
  end
end
