# frozen_string_literal: true

class Weight < ApplicationRecord
  belongs_to :user

  validates :weight_date, presence: true
  validates :value, presence: true
  enum :weight_unit, { kg: WEIGHTS::KG, lbs: WEIGHTS::LBS }, prefix: true, validate: true
end
