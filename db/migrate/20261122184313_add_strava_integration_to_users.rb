# frozen_string_literal: true

class AddStravaIntegrationToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users, bulk: true do |table|
      table.bigint :strava_athlete_id
      table.text :strava_access_token
      table.text :strava_refresh_token
      table.datetime :strava_token_expires_at
    end

    add_index :users, :strava_athlete_id, unique: true
  end
end
