# frozen_string_literal: true

class CreateWorkoutPlanSessions < ActiveRecord::Migration[8.0]
  def change
    create_workout_plan_sessions_table
    add_index :workout_plan_sessions, %i[workout_plan_id session_date], unique: true
  end

  def create_workout_plan_sessions_table
    create_table :workout_plan_sessions do |table|
      add_plan_relation(table)
      add_session_fields(table)
      table.timestamps
    end
  end

  def add_plan_relation(table)
    table.references :workout_plan, null: false, foreign_key: true
  end

  def add_session_fields(table)
    table.date :session_date, null: false
    table.integer :workout_type, null: false
    table.float :duration
    table.float :distance
    table.string :distance_unit, default: 'km', null: false
    table.string :weight_unit, default: 'kg', null: false
    table.jsonb :details, default: {}, null: false
    table.string :title
    table.text :notes
  end
end
