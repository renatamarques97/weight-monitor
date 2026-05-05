class RemoveDefaultWeightDateFromWeights < ActiveRecord::Migration[7.1]
  def change
    change_column_default :weights, :weight_date, from: Date.new(2023, 1, 1), to: nil
  end
end
