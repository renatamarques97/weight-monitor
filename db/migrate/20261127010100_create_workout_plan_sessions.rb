# frozen_string_literal: true

class CreateWorkoutPlanSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :workout_plan_sessions do |t|
      t.references :workout_plan, null: false, foreign_key: true
      t.date :session_date, null: false
      t.integer :workout_type, null: false
      t.float :duration
      t.float :distance
      t.string :distance_unit, default: 'km', null: false
      t.string :weight_unit, default: 'kg', null: false
      t.jsonb :details, default: {}, null: false
      t.string :title
      t.text :notes

      t.timestamps
    end

    add_index :workout_plan_sessions, %i[workout_plan_id session_date], unique: true
  end
end
