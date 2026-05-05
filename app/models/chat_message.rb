# frozen_string_literal: true

class ChatMessage < ApplicationRecord
  belongs_to :user

  validates :role, presence: true, inclusion: { in: %w[user assistant system] }
  validates :content, presence: true

  scope :ordered, -> { order(:created_at, :id) }
end
