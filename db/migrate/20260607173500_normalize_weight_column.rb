# frozen_string_literal: true

class NormalizeWeightColumn < ActiveRecord::Migration[8.0]
  def up
    return unless table_exists?(:weights)

    if column_exists?(:weights, :value) && !column_exists?(:weights, :kg)
      rename_column :weights, :value, :kg
    elsif !column_exists?(:weights, :kg)
      add_column :weights, :kg, :float, null: false, default: 0.0
    end

    change_column_default :weights, :kg, from: 0.0, to: nil
  end

  def down
    return unless table_exists?(:weights)

    rename_column :weights, :kg, :value if column_exists?(:weights, :kg)
  end
end
