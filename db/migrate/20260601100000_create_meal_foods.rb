# frozen_string_literal: true

class CreateMealFoods < ActiveRecord::Migration[8.0]
  def change
    create_table :meal_foods do |table|
      add_references(table)
      add_nutrition_fields(table)
      table.timestamps
    end
  end

  def add_references(table)
    table.references :meal, null: false, foreign_key: true
  end

  def add_nutrition_fields(table)
    table.string :food_name, null: false
    table.string :fatsecret_food_id
    table.float :calories
    table.float :protein
    table.float :carbs
    table.float :fat
    table.string :metric_serving_unit
  end
end
