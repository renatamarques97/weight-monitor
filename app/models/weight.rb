class Weight < ApplicationRecord
  belongs_to :user

  validates :weight_date, presence: true
  validates :kg, presence: true
end
