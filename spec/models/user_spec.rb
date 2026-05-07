require 'rails_helper'

RSpec.describe User, type: :model do
  describe "relations" do
    it { is_expected.to have_many(:diets).dependent(:destroy) }
    it { is_expected.to have_many(:weights).dependent(:destroy) }
    it { is_expected.to have_many(:workouts).dependent(:destroy) }
  end

  describe "validations" do
    let!(:user) { create(:user) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
  end

  describe "workout helpers" do
    let(:user) { create(:user) }

    it "defines singular and plural methods for each workout type" do
      WorkoutType::MAPPING.keys.each do |workout_type|
        expect(user).to respond_to(workout_type)
        expect(user).to respond_to(workout_type.to_s.pluralize)
      end
    end

    it "returns workouts filtered by type" do
      create(:running, user: user)
      create(:running, user: user)
      create(:cycling, user: user)

      expect(user.runnings.count).to eq(2)
      expect(user.cyclings.count).to eq(1)
    end
  end
end
