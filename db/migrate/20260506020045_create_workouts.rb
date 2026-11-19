# frozen_string_literal: true

class CreateWorkouts < ActiveRecord::Migration[8.0]
  def change
    create_workouts_table
    drop_runnings_table
  end

  def create_workouts_table
    create_table :workouts do |table|
      table.references :user, null: false, foreign_key: true
      table.integer :workout_type, null: false, default: 0
      table.date :workout_date, null: false
      table.float :duration, null: false
      table.float :distance
      table.integer :calories
      table.jsonb :details, default: {}, null: false
      table.timestamps
    end
  end

  def drop_runnings_table
    drop_table :runnings do |table|
      table.float :duration, null: false
      table.float :distance, null: false
      table.float :avg_pace
      table.references :user, null: false, foreign_key: true
      table.date :running_date, null: false
      table.timestamps
    end
  end
end
