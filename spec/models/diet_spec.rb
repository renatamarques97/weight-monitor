require 'rails_helper'

RSpec.describe Diet, type: :model do
  describe "relations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:initial_weight) }
    it { is_expected.to validate_presence_of(:target_weight) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_numericality_of(:initial_weight).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:target_weight).is_greater_than(0) }
  end

  describe "nested attributes" do
    it{ is_expected.to accept_nested_attributes_for(:meals) }
  end
end
