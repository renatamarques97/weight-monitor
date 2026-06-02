require 'rails_helper'

RSpec.describe Meal, type: :model do
  describe "relations" do
    it { is_expected.to belong_to(:diet).optional }
    it { is_expected.to belong_to(:meal_diary).optional }
    it { is_expected.to have_many(:meal_foods).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:schedule) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:meal_type) }
    it { is_expected.to enumerize(:meal_type) }

    it 'is invalid without diet and meal_diary' do
      meal = build(:meal, diet: nil, meal_diary: nil)

      expect(meal).not_to be_valid
      expect(meal.errors[:base]).to include('Meal must belong to a diet or meal diary')
    end

    it 'is valid with meal_diary when diet is nil' do
      meal_diary = create(:meal_diary)
      meal = build(:meal, diet: nil, meal_diary: meal_diary)

      expect(meal).to be_valid
    end
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:meal_foods) }
  end
end
