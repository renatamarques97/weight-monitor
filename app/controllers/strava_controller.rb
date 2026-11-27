# frozen_string_literal: true

class StravaController < ApplicationController
  before_action :authenticate_user!

  def connect
    redirect_to strava_service.authorization_url(strava_callback_url), allow_other_host: true
  end

  def callback
    strava_service.exchange_code(params.require(:code))
    redirect_to workouts_path, notice: t('strava.connected')
  rescue ActionController::ParameterMissing, StravaApiService::Error => e
    redirect_to workouts_path, alert: t('strava.connect_error', message: e.message)
  end

  def sync
    return already_syncing unless current_user.start_strava_sync?

    perform_strava_sync
  end

  def perform_strava_sync
    imported = StravaActivitySyncService.new(current_user).sync
    mark_strava_synced(imported)
    redirect_to workouts_path, notice: t('strava.sync_success', count: imported)
  rescue StandardError => e
    mark_strava_failed(e)
  end

  def already_syncing
    redirect_to workouts_path, alert: t('strava.already_syncing')
  end

  def mark_strava_synced(imported)
    current_user.update!(
      strava_sync_status: 'synced',
      strava_sync_finished_at: Time.current,
      strava_sync_imported_count: imported,
      strava_sync_error: nil
    )
  end

  def mark_strava_failed(error)
    current_user.update!(
      strava_sync_status: 'failed',
      strava_sync_finished_at: Time.current,
      strava_sync_error: error.message
    )
    redirect_to workouts_path, alert: t('strava.sync_error', message: error.message)
  end

  def status
    current_user.expire_stale_strava_sync!

    render json: {
      status: current_user.strava_sync_status,
      imported_count: current_user.strava_sync_imported_count,
      error: current_user.strava_sync_error,
      finished_at: current_user.strava_sync_finished_at
    }
  end

  def disconnect
    current_user.update!(
      strava_athlete_id: nil,
      strava_access_token: nil,
      strava_refresh_token: nil,
      strava_token_expires_at: nil
    )

    redirect_to workouts_path, notice: t('strava.disconnected')
  end

  private

  def strava_service
    StravaApiService.new(current_user)
  end
end
