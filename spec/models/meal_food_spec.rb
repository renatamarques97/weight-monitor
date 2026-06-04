require 'rails_helper'

RSpec.describe MealFood, type: :model do
  describe 'relations' do
    it { is_expected.to belong_to(:meal) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:food_name) }
    it { is_expected.to validate_numericality_of(:metric_serving_amount).is_greater_than(0) }
    it { is_expected.to allow_value(nil).for(:metric_serving_amount) }
  end
end
