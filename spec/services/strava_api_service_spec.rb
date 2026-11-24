# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StravaApiService do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('STRAVA_CLIENT_ID').and_return('123')
    allow(ENV).to receive(:fetch).with('STRAVA_CLIENT_SECRET').and_return('secret')
  end

  describe '#authorization_url' do
    it 'builds the OAuth authorization URL' do
      url = service.authorization_url('http://localhost:3000/strava/callback')

      expect(url).to start_with('https://www.strava.com/oauth/authorize?')
      expect(url).to include('client_id=123')
      expect(url).to include('scope=activity%3Aread_all')
    end
  end

  describe '#exchange_code' do
    it 'stores tokens returned after authorization' do
      response = Net::HTTPOK.new('1.1', '200', 'OK')
      allow(response).to receive(:body).and_return({
        access_token: 'access', refresh_token: 'refresh', expires_at: 1.hour.from_now.to_i,
        athlete: { id: 456 }
      }.to_json)
      allow(Net::HTTP).to receive(:post_form).and_return(response)

      expect(service.exchange_code('authorization-code')).to eq('access')
      expect(user.reload.strava_access_token).to eq('access')
      expect(user.strava_refresh_token).to eq('refresh')
      expect(user.strava_athlete_id).to eq(456)
    end

    it 'raises a service error for an invalid token response' do
      response = Net::HTTPBadRequest.new('1.1', '400', 'Bad Request')
      allow(response).to receive(:body).and_return({ message: 'Bad code' }.to_json)
      allow(Net::HTTP).to receive(:post_form).and_return(response)

      expect { service.exchange_code('bad-code') }
        .to raise_error(StravaApiService::Error, 'Bad code')
    end
  end

  describe '#refresh_token' do
    it 'raises an error when the user is not connected' do
      expect { service.refresh_token }.to raise_error(StravaApiService::Error, 'Strava is not connected')
    end

    it 'renews and stores the tokens' do
      user.update!(strava_refresh_token: 'old-refresh')
      response = Net::HTTPOK.new('1.1', '200', 'OK')
      allow(response).to receive(:body).and_return({
        access_token: 'new-access', refresh_token: 'new-refresh', expires_at: 2.hours.from_now.to_i
      }.to_json)
      allow(Net::HTTP).to receive(:post_form).and_return(response)

      expect(service.refresh_token).to eq('new-access')
      expect(user.reload.strava_access_token).to eq('new-access')
      expect(user.strava_refresh_token).to eq('new-refresh')
    end
  end

  describe '#access_token' do
    it 'refreshes an expired access token' do
      user.update!(
        strava_access_token: 'old-access',
        strava_refresh_token: 'refresh',
        strava_token_expires_at: 1.minute.ago
      )
      response = Net::HTTPOK.new('1.1', '200', 'OK')
      allow(response).to receive(:body).and_return({
        access_token: 'new-access', refresh_token: 'refresh', expires_at: 1.hour.from_now.to_i
      }.to_json)
      allow(Net::HTTP).to receive(:post_form).and_return(response)

      expect(service.access_token).to eq('new-access')
    end
  end

  describe '#activities' do
    it 'returns parsed activities' do
      user.update!(strava_access_token: 'access', strava_token_expires_at: 1.hour.from_now)
      response = Net::HTTPOK.new('1.1', '200', 'OK')
      allow(response).to receive(:body).and_return([{ id: 123 }].to_json)
      http = instance_double(Net::HTTP, request: response)
      allow(Net::HTTP).to receive(:start).and_yield(http).and_return(response)

      expect(service.activities(per_page: 10, page: 2)).to eq([{ 'id' => 123 }])
    end

    it 'raises an error for an invalid JSON response' do
      user.update!(strava_access_token: 'access', strava_token_expires_at: 1.hour.from_now)
      response = Net::HTTPOK.new('1.1', '200', 'OK')
      allow(response).to receive(:body).and_return('not-json')
      http = instance_double(Net::HTTP, request: response)
      allow(Net::HTTP).to receive(:start).and_yield(http).and_return(response)

      expect { service.activities }.to raise_error(StravaApiService::Error, 'Invalid response received from Strava')
    end

    it 'raises an error for an unsuccessful API response' do
      user.update!(strava_access_token: 'access', strava_token_expires_at: 1.hour.from_now)
      response = Net::HTTPUnauthorized.new('1.1', '401', 'Unauthorized')
      allow(response).to receive(:body).and_return('{}')
      http = instance_double(Net::HTTP, request: response)
      allow(Net::HTTP).to receive(:start).and_yield(http).and_return(response)

      expect { service.activities }.to raise_error(StravaApiService::Error, /401/)
    end
  end
end
