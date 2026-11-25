# frozen_string_literal: true

# Guarded so it is safe on every database state in the wild:
# - databases migrated on master (weights.kg, no unit columns);
# - databases loaded from master's schema.rb (weights.kg, unit columns already present);
# - local databases that ran the earlier version of this migration (weights.value, unit columns present).
class AddUnitPreferencesAndRenameWeightColumn < ActiveRecord::Migration[8.0]
  UNIT_COLUMNS = {
    users: { weight_unit: 'kg', distance_unit: 'km', height_unit: 'm' },
    weights: { weight_unit: 'kg' },
    diets: { weight_unit: 'kg' },
    workouts: { distance_unit: 'km', weight_unit: 'kg' }
  }.freeze

  def up
    UNIT_COLUMNS.each do |table, columns|
      columns.each do |column, default|
        add_column table, column, :string, null: false, default: default unless column_exists?(table, column)
      end
    end

    rename_column :weights, :kg, :value if column_exists?(:weights, :kg) && !column_exists?(:weights, :value)
  end

  def down
    rename_column :weights, :value, :kg if column_exists?(:weights, :value) && !column_exists?(:weights, :kg)

    UNIT_COLUMNS.each do |table, columns|
      columns.each_key do |column|
        remove_column table, column if column_exists?(table, column)
      end
    end
  end
end
