# frozen_string_literal: true

class EncryptExistingStravaTokens < ActiveRecord::Migration[8.0]
  class MigrationUser < ActiveRecord::Base
    self.table_name = 'users'

    encrypts :strava_access_token, deterministic: false
    encrypts :strava_refresh_token, deterministic: false
  end

  def up
    MigrationUser.where.not(strava_access_token: nil).or(
      MigrationUser.where.not(strava_refresh_token: nil)
    ).find_each do |user|
      access_token = user.strava_access_token
      refresh_token = user.strava_refresh_token

      user.update!(
        strava_access_token: access_token,
        strava_refresh_token: refresh_token
      )
    end
  end

  def down = nil
end
