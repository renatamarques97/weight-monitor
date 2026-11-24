# frozen_string_literal: true

class StravaSyncJob < ApplicationJob
  queue_as :default

  discard_on ActiveJob::DeserializationError

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    mark_syncing(user)
    imported = StravaActivitySyncService.new(user).sync
    mark_synced(user, imported)
  rescue StandardError => e
    mark_failed(user, e)
  end

  private

  def mark_syncing(user)
    user.update!(
      strava_sync_status: 'syncing',
      strava_sync_started_at: Time.current,
      strava_sync_finished_at: nil,
      strava_sync_error: nil
    )
  end

  def mark_synced(user, imported)
    user.update!(
      strava_sync_status: 'synced',
      strava_sync_finished_at: Time.current,
      strava_sync_imported_count: imported,
      strava_sync_error: nil
    )
  end

  def mark_failed(user, error)
    user&.update!(
      strava_sync_status: 'failed',
      strava_sync_finished_at: Time.current,
      strava_sync_error: error.message
    )
  end
end
