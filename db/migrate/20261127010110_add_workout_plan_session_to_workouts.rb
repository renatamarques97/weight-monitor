# frozen_string_literal: true

class AddWorkoutPlanSessionToWorkouts < ActiveRecord::Migration[8.0]
  def change
    add_reference :workouts, :workout_plan_session, null: true, foreign_key: true, index: false
    add_index :workouts, :workout_plan_session_id, unique: true
  end
end
