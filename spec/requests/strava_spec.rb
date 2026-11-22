# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/strava', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /strava/connect' do
    it 'redirects to the Strava authorization URL' do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('STRAVA_CLIENT_ID').and_return('123')

      get strava_connect_path

      expect(response).to redirect_to(%r{https://www\.strava\.com/oauth/authorize})
    end
  end

  describe 'GET /strava/callback' do
    it 'stores the authorization and redirects to workouts' do
      service = instance_double(StravaApiService)
      allow(StravaApiService).to receive(:new).with(user).and_return(service)
      allow(service).to receive(:exchange_code).with('valid-code').and_return('access')

      get strava_callback_path, params: { code: 'valid-code' }

      expect(response).to redirect_to(workouts_path)
      expect(flash[:notice]).to eq('Strava conectado com sucesso.')
    end

    it 'shows an alert when the authorization is rejected' do
      get strava_callback_path

      expect(response).to redirect_to(workouts_path)
      expect(flash[:alert]).to include('Não foi possível conectar ao Strava')
    end

    it 'shows an alert when Strava rejects the token exchange' do
      service = instance_double(StravaApiService)
      allow(StravaApiService).to receive(:new).with(user).and_return(service)
      allow(service).to receive(:exchange_code).and_raise(StravaApiService::Error, 'Invalid code')

      get strava_callback_path, params: { code: 'bad-code' }

      expect(response).to redirect_to(workouts_path)
      expect(flash[:alert]).to include('Invalid code')
    end
  end

  describe 'POST /strava/sync' do
    it 'reports imported activities' do
      sync_service = instance_double(StravaActivitySyncService, sync: 3)
      allow(StravaActivitySyncService).to receive(:new).with(user).and_return(sync_service)

      post strava_sync_path

      expect(response).to redirect_to(workouts_path)
      expect(flash[:notice]).to include('3 atividade(s)')
    end

    it 'shows an alert when synchronization fails' do
      allow(StravaActivitySyncService).to receive(:new).and_raise(StravaApiService::Error, 'Token expired')

      post strava_sync_path

      expect(response).to redirect_to(workouts_path)
      expect(flash[:alert]).to include('Token expired')
    end
  end

  describe 'DELETE /strava/disconnect' do
    it 'removes stored Strava credentials' do
      user.update!(
        strava_athlete_id: 123,
        strava_access_token: 'access',
        strava_refresh_token: 'refresh',
        strava_token_expires_at: 1.hour.from_now
      )

      delete strava_disconnect_path

      expect(response).to redirect_to(workouts_path)
      expect(user.reload.strava_athlete_id).to be_nil
      expect(user.strava_access_token).to be_nil
    end
  end
end
