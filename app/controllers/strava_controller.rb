# frozen_string_literal: true

class StravaController < ApplicationController
  before_action :authenticate_user!

  def connect
    redirect_to strava_service.authorization_url(strava_callback_url), allow_other_host: true
  end

  def callback
    strava_service.exchange_code(params.require(:code))
    redirect_to workouts_path, notice: 'Strava conectado com sucesso.'
  rescue ActionController::ParameterMissing, StravaApiService::Error => e
    redirect_to workouts_path, alert: "Não foi possível conectar ao Strava: #{e.message}"
  end

  def sync
    imported = StravaActivitySyncService.new(current_user).sync
    redirect_to workouts_path, notice: "#{imported} atividade(s) importada(s) do Strava."
  rescue StravaApiService::Error => e
    redirect_to workouts_path, alert: "Não foi possível sincronizar: #{e.message}"
  end

  def disconnect
    current_user.update!(
      strava_athlete_id: nil,
      strava_access_token: nil,
      strava_refresh_token: nil,
      strava_token_expires_at: nil
    )

    redirect_to workouts_path, notice: 'Strava desconectado.'
  end

  private

  def strava_service
    StravaApiService.new(current_user)
  end
end
