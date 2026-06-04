class AddMealDiaryRefToMeals < ActiveRecord::Migration[8.0]
  def change
    add_reference :meals, :meal_diary, foreign_key: true
    change_column_null :meals, :diet_id, true
  end
end
