require 'rails_helper'

RSpec.describe Weight, type: :model do
  describe "relations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:weight_date) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_inclusion_of(:weight_unit).in_array(WEIGHTS::ALL) }
  end

  describe "record-level unit persistence" do
    let(:user) { create(:user, weight_unit: WEIGHTS::LBS) }

    it "stores the value exactly as entered (no conversion)" do
      weight = create(:weight, user: user, value: 154.32, weight_unit: WEIGHTS::LBS)
      expect(weight.value).to eq(154.32)
      expect(weight.weight_unit).to eq(WEIGHTS::LBS)
    end

    it "defaults weight_unit to kg when not specified" do
      weight = create(:weight, user: user, value: 70.0)
      expect(weight.weight_unit).to eq(WEIGHTS::KG)
    end
  end
end
