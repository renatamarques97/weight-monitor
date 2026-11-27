# frozen_string_literal: true

class User < ApplicationRecord
  include StravaSyncState

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :weights, dependent: :destroy
  has_many :diets, dependent: :destroy
  has_many :meal_diaries, dependent: :destroy
  has_many :workouts, dependent: :destroy
  has_many :chat_messages, dependent: :destroy
  has_one :professional_assignment, foreign_key: :client_id, dependent: :destroy,
                                    inverse_of: :client
  has_many :nutritionist_assignments, class_name: 'ProfessionalAssignment',
                                      foreign_key: :nutritionist_id, dependent: :nullify, inverse_of: :nutritionist
  has_many :physical_educator_assignments,
           class_name: 'ProfessionalAssignment',
           foreign_key: :physical_educator_id,
           dependent: :nullify,
           inverse_of: :physical_educator
  has_many :workout_plans, dependent: :destroy

  def current_diet
    diets.order(start_date: :desc, created_at: :desc).first
  end

  encrypts :strava_access_token, deterministic: false
  encrypts :strava_refresh_token, deterministic: false

  validates :email, uniqueness: true
  validates :name, presence: true
  validates :height, numericality: { greater_than: 0 }, allow_nil: true
  validate :professional_fields_consistent

  enum :weight_unit, { kg: WEIGHTS::KG, lbs: WEIGHTS::LBS }, prefix: true, validate: true
  enum :distance_unit, { km: DISTANCES::KM, mi: DISTANCES::MI }, prefix: true, validate: true
  enum :height_unit, { m: HEIGHTS::M, ft: HEIGHTS::FT, cm: HEIGHTS::CM }, prefix: true, validate: true
  enum :account_type, { free: 0, premium: 1, professional: 2, admin: 3 }, prefix: true, validate: true
  enum :professional_type, { nutritionist: 0, physical_educator: 1 }, prefix: true

  before_validation :parse_height_in_feet, if: :height_unit_ft?

  WorkoutType::MAPPING.each_key do |workout_type|
    define_method workout_type.to_s do
      workouts.send(workout_type)
    end

    define_method workout_type.to_s.pluralize do
      workouts.send(workout_type)
    end
  end

  def valid_nutritionist?
    account_type_professional? && professional_type_nutritionist? && professional_credentials_present?
  end

  def valid_physical_educator?
    account_type_professional? && professional_type_physical_educator? && professional_credentials_present?
  end

  def nutritionist
    professional_assignment&.nutritionist
  end

  def physical_educator
    professional_assignment&.physical_educator
  end

  def current_workout_plan
    workout_plans.order(start_date: :desc, created_at: :desc).first
  end

  def professional_credentials_present?
    country_code.present? && professional_credential.present? && professional_registration_number.present?
  end

  private

  def professional_fields_consistent
    return unless account_type_professional?

    if professional_type.blank?
      errors.add(:professional_type, 'must be selected')
    elsif professional_credentials_present? == false
      errors.add(:base, 'country, credential and registration number are required')
    end
  end

  # Accepts 5'9" as well as decimal feet; unparseable input is kept so validation reports it.
  def parse_height_in_feet
    raw_height = height_before_type_cast
    return unless raw_height.is_a?(String)

    parsed = FeetAndInches.parse(raw_height)
    self.height = parsed if parsed
  end
end
