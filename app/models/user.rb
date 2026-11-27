# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :weights, dependent: :destroy
  has_many :diets, dependent: :destroy
  has_many :meal_diaries, dependent: :destroy
  has_many :workouts, dependent: :destroy
  has_many :chat_messages, dependent: :destroy

  def current_diet
    diets.order(start_date: :desc, created_at: :desc).first
  end

  encrypts :strava_access_token, deterministic: false
  encrypts :strava_refresh_token, deterministic: false

  validates :email, uniqueness: true
  validates :name, presence: true
  validates :height, numericality: { greater_than: 0 }, allow_nil: true

  enum :weight_unit, { kg: WEIGHTS::KG, lbs: WEIGHTS::LBS }, prefix: true, validate: true
  enum :distance_unit, { km: DISTANCES::KM, mi: DISTANCES::MI }, prefix: true, validate: true
  enum :height_unit, { m: HEIGHTS::M, ft: HEIGHTS::FT, cm: HEIGHTS::CM }, prefix: true, validate: true

  before_validation :parse_height_in_feet, if: :height_unit_ft?

  WorkoutType::MAPPING.each_key do |workout_type|
    define_method workout_type.to_s do
      workouts.send(workout_type)
    end

    define_method workout_type.to_s.pluralize do
      workouts.send(workout_type)
    end
  end

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

  def meal_diary_streak
    @meal_diary_streak ||= MealDiaryStreakPresenter.new(self)
  end

  def weight_streak
    @weight_streak ||= WeightStreakPresenter.new(self)
  end

  def workout_streak
    @workout_streak ||= WorkoutStreakPresenter.new(self)
  end

  private

  # Accepts 5'9" as well as decimal feet; unparseable input is kept so validation reports it.
  def parse_height_in_feet
    raw_height = height_before_type_cast
    return unless raw_height.is_a?(String)

    parsed = FeetAndInches.parse(raw_height)
    self.height = parsed if parsed
  end
end
