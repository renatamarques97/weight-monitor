require 'rails_helper'

RSpec.describe User, type: :model do
  describe "relations" do
    it { is_expected.to have_many(:diets).dependent(:destroy) }
    it { is_expected.to have_many(:weights).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
  end
end
