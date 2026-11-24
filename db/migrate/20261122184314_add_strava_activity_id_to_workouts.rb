# frozen_string_literal: true

class AddStravaActivityIdToWorkouts < ActiveRecord::Migration[8.0]
  def change
    add_column :workouts, :strava_activity_id, :bigint
    add_index :workouts, %i[user_id strava_activity_id],
              unique: true,
              where: 'strava_activity_id IS NOT NULL'
  end
end
