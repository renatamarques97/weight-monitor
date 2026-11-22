# frozen_string_literal: true

class AddStravaSyncStatusToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users, bulk: true do |table|
      table.string :strava_sync_status, default: 'idle', null: false
      table.datetime :strava_sync_started_at
      table.datetime :strava_sync_finished_at
      table.text :strava_sync_error
      table.integer :strava_sync_imported_count, default: 0, null: false
    end
  end
end
