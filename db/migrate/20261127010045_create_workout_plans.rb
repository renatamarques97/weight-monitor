# frozen_string_literal: true

class CreateWorkoutPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :workout_plans do |t|
      t.references :user, null: false, foreign_key: true
      t.references :physical_educator, null: false, foreign_key: { to_table: :users }
      t.date :start_date, null: false
      t.date :end_date, null: false

      t.timestamps
    end

    add_index :workout_plans, %i[user_id start_date]
  end
end
