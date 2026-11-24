# frozen_string_literal: true

class ReplaceGlobalStravaActivityIndex < ActiveRecord::Migration[8.0]
  def change
    remove_index :workouts, :strava_activity_id,
                 if_exists: true,
                 where: 'strava_activity_id IS NOT NULL'
    remove_index :workouts, :strava_activity_id,
                 if_exists: true

    add_index :workouts, %i[user_id strava_activity_id],
              unique: true,
              where: 'strava_activity_id IS NOT NULL'
  end
end
