# frozen_string_literal: true

class Running < ApplicationRecord
  belongs_to :user

  validates :duration, presence: true
  validates :distance, presence: true
  after_validation :average_pace, on: [ :create, :update ]

  def average_pace
    self.avg_pace = self.duration / self.distance
  end
end