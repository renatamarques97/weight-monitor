class AddUnitPreferencesAndRenameWeightColumn < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :weight_unit, :string, default: MeasurementUnits::WEIGHTS::KG, null: false
    add_column :users, :distance_unit, :string, default: MeasurementUnits::DISTANCES::KM, null: false
    add_column :users, :height_unit, :string, default: MeasurementUnits::HEIGHTS::M, null: false

    add_column :weights, :weight_unit, :string, null: false, default: MeasurementUnits::WEIGHTS::KG
    add_column :diets, :weight_unit, :string, null: false, default: MeasurementUnits::WEIGHTS::KG
    add_column :workouts, :distance_unit, :string, null: false, default: MeasurementUnits::DISTANCES::KM
    add_column :workouts, :weight_unit, :string, null: false, default: MeasurementUnits::WEIGHTS::KG

    rename_column :weights, :kg, :value
  end
end
