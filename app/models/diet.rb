# frozen_string_literal: true

class Diet < ApplicationRecord
  belongs_to :user
  has_many :meals, dependent: :destroy

  validates :initial_weight, presence: true
  validates :target_weight, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :initial_weight, numericality: { greater_than: 0 }
  validates :target_weight, numericality: { greater_than: 0 }
  validates :end_date, date: { after_or_equal_to:  :start_date }

  accepts_nested_attributes_for :meals, reject_if: :all_blank, allow_destroy: true

  scope :authorized_user, ->(user) { where(user_id: user.id) }

  def initial_weight=(value)
    super(weight_with_one_decimal(value))
  end

  def target_weight=(value)
    super(weight_with_one_decimal(value))
  end

  private

  def weight_with_one_decimal(value)
    numeric_value = Float(value, exception: false)
    numeric_value ? numeric_value.round(1) : value
  end
end
