class RemoveDefaultDatesFromDiets < ActiveRecord::Migration[7.1]
  def change
    change_column_default :diets, :start_date, from: Date.new(2023, 1, 1), to: nil
    change_column_default :diets, :end_date, from: Date.new(2023, 1, 1), to: nil
  end
end
