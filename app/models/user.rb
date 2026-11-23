# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :weights, dependent: :destroy
  has_many :diets, dependent: :destroy
  has_many :meal_diaries, dependent: :destroy
  has_many :workouts, dependent: :destroy
  has_many :chat_messages, dependent: :destroy

  encrypts :strava_access_token, deterministic: false
  encrypts :strava_refresh_token, deterministic: false

  validates :email, uniqueness: true
  validates :name, presence: true
  validates :height, numericality: { greater_than: 0 }, allow_nil: true

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
end
