class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :weights, dependent: :destroy
  has_many :diets, dependent: :destroy
  has_many :runnings, dependent: :destroy
  has_many :chat_messages, dependent: :destroy

  validates_uniqueness_of :email
  validates :name, presence: true
  validates :height, numericality: { greater_than: 0 }, allow_nil: true
end
