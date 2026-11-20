# frozen_string_literal: true

class ChangeWeightType < ActiveRecord::Migration[7.1]
  def up
    change_table :diets, bulk: true do |table|
      table.float :initial_weight
      table.float :target_weight
    end
  end

  def down
    change_table :diets, bulk: true do |table|
      table.decimal :initial_weight
      table.decimal :target_weight
    end
  end
end
