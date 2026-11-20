# frozen_string_literal: true

class AddMacrosToMeals < ActiveRecord::Migration[8.0]
  def change
    change_table :meals, bulk: true do |table|
      table.float :calories
      table.float :protein
      table.float :carbs
      table.float :fat
      table.string :food_name
      table.string :fatsecret_food_id
      table.string :metric_serving_unit
    end
  end
end
