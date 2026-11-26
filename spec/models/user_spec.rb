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

  describe 'account types' do
    it 'defaults to a free account' do
      expect(build(:user).account_type).to eq('free')
    end

    it 'requires a professional type for professional accounts' do
      user = build(:user, account_type: :professional)

      expect(user).not_to be_valid
      expect(user.errors[:professional_type]).to be_present
    end

    it 'requires generic credentials for nutrition professionals' do
      user = build(:user, account_type: :professional, professional_type: :nutritionist)

      expect(user).not_to be_valid
      expect(user.errors[:country_code]).to be_present
      expect(user.errors[:professional_credential]).to be_present
      expect(user.errors[:professional_registration_number]).to be_present
    end

    it 'accepts a Brazilian nutrition professional with CRN' do
      user = build(
        :user,
        account_type: :professional,
        professional_type: :nutritionist,
        country_code: 'BR',
        professional_credential: 'CRN',
        professional_registration_number: '12345'
      )

      expect(user).to be_valid
    end

    it 'accepts a United States physical education professional with NASM' do
      user = build(
        :user,
        account_type: :professional,
        professional_type: :physical_educator,
        country_code: 'US',
        professional_credential: 'NASM',
        professional_registration_number: '123456'
      )

      expect(user).to be_valid
    end
  end

  describe 'unit preferences' do
    let(:user) { build(:user, height: 1.75, height_unit: Units::HEIGHTS::FT) }

    it 'stores height directly with its own unit' do
      expect(user.height).to eq(1.75)
      expect(user.height_unit).to eq(Units::HEIGHTS::FT)
    end

    it 'validates accepted unit values' do
      user.weight_unit = 'stones'
      expect(user).not_to be_valid
      expect(user.errors[:weight_unit]).to be_present

      user.weight_unit = Units::WEIGHTS::KG
      user.height_unit = Units::HEIGHTS::CM
      expect(user).to be_valid
    end

    it 'accepts height in feet and inches' do
      user.height = %(5'9")
      user.validate

      expect(user.height).to eq(5.75)
    end

    it 'rejects a height in feet that cannot be read' do
      user.height = 'tall'

      expect(user).not_to be_valid
      expect(user.errors[:height]).to be_present
    end

    it 'does not read feet and inches for other units' do
      user.assign_attributes(height_unit: Units::HEIGHTS::M, height: %(5'9"))

      expect(user).not_to be_valid
    end
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

  describe 'Strava synchronization state' do
    let(:user) { create(:user) }

    it 'starts synchronization when idle' do
      expect(user.start_strava_sync?).to be(true)
      expect(user.reload.strava_sync_status).to eq('syncing')
    end

    it 'does not start synchronization while another job is active' do
      user.update!(strava_sync_status: 'syncing', strava_sync_started_at: 1.minute.ago)

      expect(user.start_strava_sync?).to be(false)
      expect(user.reload.strava_sync_status).to eq('syncing')
    end

    it 'expires stale synchronization' do
      user.update!(strava_sync_status: 'syncing', strava_sync_started_at: 16.minutes.ago)

      user.expire_stale_strava_sync!

      expect(user.reload.strava_sync_status).to eq('failed')
      expect(user.strava_sync_error).to eq('Strava synchronization timed out')
    end
  end
end
