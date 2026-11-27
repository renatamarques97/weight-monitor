# frozen_string_literal: true

module StravaSyncState
  extend ActiveSupport::Concern

  STRAVA_SYNC_TIMEOUT = 15.minutes

  def strava_sync_active?
    strava_sync_status == 'syncing' && strava_sync_started_at.present? &&
      strava_sync_started_at > STRAVA_SYNC_TIMEOUT.ago
  end

  def expire_stale_strava_sync!
    return unless strava_sync_status == 'syncing'
    return if strava_sync_started_at.present? && strava_sync_started_at > STRAVA_SYNC_TIMEOUT.ago

    update!(
      strava_sync_status: 'failed',
      strava_sync_finished_at: Time.current,
      strava_sync_error: 'Strava synchronization timed out'
    )
  end

  def start_strava_sync?
    with_lock do
      expire_stale_strava_sync!
      return false if strava_sync_active?

      mark_strava_syncing!
    end

    true
  end

  def mark_strava_syncing!
    update!(
      strava_sync_status: 'syncing',
      strava_sync_started_at: Time.current,
      strava_sync_finished_at: nil,
      strava_sync_error: nil
    )
  end
end
