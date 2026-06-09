class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :weights, dependent: :destroy
  has_many :diets, dependent: :destroy
  has_many :meal_diaries, dependent: :destroy
  has_many :workouts, dependent: :destroy
  has_many :chat_messages, dependent: :destroy

  validates_uniqueness_of :email
  validates :name, presence: true
  validates :height, numericality: { greater_than: 0 }, allow_nil: true

  enum :weight_unit, { kg: WEIGHTS::KG, lbs: WEIGHTS::LBS }, prefix: true, validate: true
  enum :distance_unit, { km: DISTANCES::KM, mi: DISTANCES::MI }, prefix: true, validate: true
  enum :height_unit, { m: HEIGHTS::M, ft: HEIGHTS::FT, cm: HEIGHTS::CM }, prefix: true, validate: true

  WorkoutType::MAPPING.keys.each do |workout_type|
    define_method workout_type.to_s do
      workouts.send(workout_type)
    end

    define_method workout_type.to_s.pluralize do
      workouts.send(workout_type)
    end
  end
end
