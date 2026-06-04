class CreateMealFoods < ActiveRecord::Migration[8.0]
  def change
    create_table :meal_foods do |t|
      t.references :meal, null: false, foreign_key: true
      t.string :food_name, null: false
      t.string :fatsecret_food_id
      t.float :calories
      t.float :protein
      t.float :carbs
      t.float :fat
      t.string :metric_serving_unit

      t.timestamps
    end
  end
end
