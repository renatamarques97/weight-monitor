# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StravaActivitySyncService do
  let(:user) { create(:user) }
  let(:walking_activity) do
    {
      'id' => 111_111,
      'sport_type' => 'Walk',
      'start_date_local' => '2026-11-20T08:30:00Z',
      'moving_time' => 1200,
      'distance' => 2000,
      'total_elevation_gain' => 25
    }
  end
  let(:swimming_activity) do
    {
      'id' => 222_222,
      'sport_type' => 'Swim',
      'start_date_local' => '2026-11-20T09:30:00Z',
      'moving_time' => 1800,
      'distance' => 1000,
      'lap_count' => 20
    }
  end
  let(:unknown_activity) do
    {
      'id' => 333_333,
      'sport_type' => 'Snowboard',
      'start_date_local' => '2026-11-20T10:30:00Z',
      'moving_time' => 3600,
      'distance' => 0,
      'calories' => nil
    }
  end

  describe '#sync' do
    it 'imports and normalizes a Strava running activity' do
      api = instance_double(StravaApiService)
      allow(StravaApiService).to receive(:new).with(user).and_return(api)
      allow(api).to receive(:activities).with(per_page: 30).and_return([
                                                                         {
                                                                           'id' => 123_456,
                                                                           'sport_type' => 'Run',
                                                                           'start_date_local' => '2026-11-20T08:30:00Z',
                                                                           'moving_time' => 2543,
                                                                           'distance' => 5000,
                                                                           'calories' => 420
                                                                         }
                                                                       ])

      expect(described_class.new(user).sync).to eq(1)

      workout = user.workouts.find_by!(strava_activity_id: 123_456)
      expect(workout).to be_a(Running)
      expect(workout.workout_date).to eq(Date.new(2026, 11, 20))
      expect(workout.duration).to eq(42.38)
      expect(workout.distance).to eq(5.0)
      expect(workout.calories).to eq(420)
    end

    it 'maps walking, swimming and unknown activities' do
      api = instance_double(StravaApiService)
      allow(StravaApiService).to receive(:new).with(user).and_return(api)
      allow(api).to receive(:activities).with(per_page: 30).and_return([
                                                                         walking_activity,
                                                                         swimming_activity,
                                                                         unknown_activity
                                                                       ])

      expect(described_class.new(user).sync).to eq(3)

      walking = user.workouts.find_by!(strava_activity_id: 111_111)
      expect(walking).to be_a(Walking)

      swimming = user.workouts.find_by!(strava_activity_id: 222_222)
      expect(swimming).to be_a(Swimming)
      expect(swimming.details.laps).to eq(20)

      other = user.workouts.find_by!(strava_activity_id: 333_333)
      expect(other).to be_a(Other)
      expect(other.distance).to be_nil
      expect(other.calories).to be_nil
    end

    it 'does not import the same Strava activity twice' do
      api = instance_double(StravaApiService)
      allow(StravaApiService).to receive(:new).with(user).and_return(api)
      activity = {
        'id' => 987_654,
        'sport_type' => 'Ride',
        'start_date_local' => '2026-11-21T08:30:00Z',
        'moving_time' => 3600,
        'distance' => 30_000,
        'average_speed' => 8.33
      }
      allow(api).to receive(:activities).with(per_page: 30).and_return([activity])

      sync_service = described_class.new(user)
      expect(sync_service.sync).to eq(1)
      expect(sync_service.sync).to eq(0)

      expect(user.workouts.where(strava_activity_id: 987_654).count).to eq(1)
    end

    it 'allows the same Strava activity ID for another user' do
      other_user = create(:user)
      create(:cycling, user: other_user, strava_activity_id: 987_654)
      api = instance_double(StravaApiService)
      allow(StravaApiService).to receive(:new).with(user).and_return(api)
      allow(api).to receive(:activities).with(per_page: 30).and_return([
                                                                         {
                                                                           'id' => 987_654,
                                                                           'sport_type' => 'Ride',
                                                                           'start_date_local' => '2026-11-21T08:30:00Z',
                                                                           'moving_time' => 3600,
                                                                           'distance' => 30_000,
                                                                           'average_speed' => 8.33
                                                                         }
                                                                       ])

      expect(described_class.new(user).sync).to eq(1)
      expect(user.workouts.where(strava_activity_id: 987_654).count).to eq(1)
    end

    it 'updates an existing synchronized workout' do
      create(:running, user: user, strava_activity_id: 555_555, duration: 10)
      api = instance_double(StravaApiService)
      allow(StravaApiService).to receive(:new).with(user).and_return(api)
      allow(api).to receive(:activities).with(per_page: 30).and_return([
                                                                         {
                                                                           'id' => 555_555,
                                                                           'sport_type' => 'Run',
                                                                           'start_date_local' => '2026-11-22T08:30:00Z',
                                                                           'moving_time' => 3600,
                                                                           'distance' => 10_000,
                                                                           'calories' => 600
                                                                         }
                                                                       ])

      expect(described_class.new(user).sync).to eq(0)
      expect(user.workouts.find_by!(strava_activity_id: 555_555).duration).to eq(60.0)
    end
  end
end
