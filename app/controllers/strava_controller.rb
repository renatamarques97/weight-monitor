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
    current_user.update!(
      strava_sync_status: 'syncing',
      strava_sync_started_at: Time.current,
      strava_sync_finished_at: nil,
      strava_sync_error: nil
    )
    StravaSyncJob.perform_later(current_user.id)

    redirect_to workouts_path
  end

  def status
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
