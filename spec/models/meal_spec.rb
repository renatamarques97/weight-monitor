require 'rails_helper'

RSpec.describe Meal, type: :model do
  describe "relations" do
    it { is_expected.to belong_to(:diet) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:schedule) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:meal_type) }
    it { is_expected.to enumerize(:meal_type) }
  end
end
