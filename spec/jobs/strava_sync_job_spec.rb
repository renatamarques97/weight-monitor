# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StravaSyncJob, type: :job do
  let(:user) { create(:user, strava_refresh_token: 'refresh') }

  it 'marks a successful synchronization' do
    sync_service = instance_double(StravaActivitySyncService, sync: 3)
    allow(StravaActivitySyncService).to receive(:new).with(user).and_return(sync_service)

    described_class.perform_now(user.id)

    expect(user.reload.strava_sync_status).to eq('synced')
    expect(user.strava_sync_imported_count).to eq(3)
    expect(user.strava_sync_error).to be_nil
  end

  it 'marks a failed synchronization' do
    sync_service = instance_double(StravaActivitySyncService)
    allow(StravaActivitySyncService).to receive(:new).with(user).and_return(sync_service)
    allow(sync_service).to receive(:sync).and_raise(StravaApiService::Error, 'Token expired')

    described_class.perform_now(user.id)

    expect(user.reload.strava_sync_status).to eq('failed')
    expect(user.strava_sync_error).to eq('Token expired')
  end

  it 'ignores a deleted user' do
    expect { described_class.perform_now(-1) }.not_to raise_error
  end
end
