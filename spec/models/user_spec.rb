# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'relations' do
    it { is_expected.to have_many(:diets).dependent(:destroy) }
    it { is_expected.to have_many(:meal_diaries).dependent(:destroy) }
    it { is_expected.to have_many(:weights).dependent(:destroy) }
    it { is_expected.to have_many(:workouts).dependent(:destroy) }
  end

  describe 'validations' do
    let!(:user) { create(:user) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
  end

  describe 'workout helpers' do
    let(:user) { create(:user) }

    it 'defines singular and plural methods for each workout type' do
      WorkoutType::MAPPING.each_key do |workout_type|
        expect(user).to respond_to(workout_type)
        expect(user).to respond_to(workout_type.to_s.pluralize)
      end
    end

    it 'returns workouts filtered by type' do
      create(:running, user: user)
      create(:running, user: user)
      create(:cycling, user: user)

      expect(user.runnings.count).to eq(2)
      expect(user.cyclings.count).to eq(1)
    end
  end

  describe 'Strava token encryption' do
    let(:user) { create(:user) }

    it 'exposes the decrypted access and refresh tokens' do
      user.update!(strava_access_token: 'access-secret', strava_refresh_token: 'refresh-secret')

      expect(user.strava_access_token).to eq('access-secret')
      expect(user.strava_refresh_token).to eq('refresh-secret')
    end

    it 'does not store Strava tokens as plaintext in the database' do
      user.update!(strava_access_token: 'access-secret', strava_refresh_token: 'refresh-secret')

      stored_tokens = ActiveRecord::Base.connection.select_one(
        'SELECT strava_access_token, strava_refresh_token FROM users WHERE id = $1',
        'strava tokens',
        [ActiveRecord::Relation::QueryAttribute.new(
          'id', user.id, ActiveRecord::Type::BigInteger.new
        )]
      )

      expect(stored_tokens['strava_access_token']).not_to eq('access-secret')
      expect(stored_tokens['strava_refresh_token']).not_to eq('refresh-secret')
    end
  end
end
