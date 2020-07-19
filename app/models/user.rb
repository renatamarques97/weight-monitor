class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :weights, dependent: :destroy
  has_many :diets, dependent: :destroy
  validates_uniqueness_of :email
end
