# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :weights, dependent: :destroy
  has_many :diets, dependent: :destroy
  has_many :meal_diaries, dependent: :destroy
  has_many :workouts, dependent: :destroy
  has_many :chat_messages, dependent: :destroy

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

  private

  # Accepts 5'9" as well as decimal feet; unparseable input is kept so validation reports it.
  def parse_height_in_feet
    raw_height = height_before_type_cast
    return unless raw_height.is_a?(String)

    parsed = FeetAndInches.parse(raw_height)
    self.height = parsed if parsed
  end
end
