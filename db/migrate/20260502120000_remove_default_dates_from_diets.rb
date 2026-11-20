# frozen_string_literal: true

class RemoveDefaultDatesFromDiets < ActiveRecord::Migration[7.1]
  def change
    change_table :diets, bulk: true do |table|
      table.change_default :start_date, from: Date.new(2023, 1, 1), to: nil
      table.change_default :end_date, from: Date.new(2023, 1, 1), to: nil
    end
  end
end
