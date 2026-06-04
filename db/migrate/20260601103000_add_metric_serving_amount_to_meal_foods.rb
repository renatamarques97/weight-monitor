class AddMetricServingAmountToMealFoods < ActiveRecord::Migration[8.0]
  def change
    add_column :meal_foods, :metric_serving_amount, :float
  end
end
