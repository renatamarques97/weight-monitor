# frozen_string_literal: true

class AddStravaIntegrationToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :strava_athlete_id, :bigint
    add_column :users, :strava_access_token, :text
    add_column :users, :strava_refresh_token, :text
    add_column :users, :strava_token_expires_at, :datetime

    add_index :users, :strava_athlete_id, unique: true
  end
end
