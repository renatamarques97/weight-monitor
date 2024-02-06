class ChangeWeightType < ActiveRecord::Migration[7.1]
  def change
    change_column(:diets, :initial_weight, :float)
    change_column(:diets, :target_weight, :float)
  end
end
