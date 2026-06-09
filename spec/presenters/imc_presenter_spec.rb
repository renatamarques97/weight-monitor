require 'rails_helper'

RSpec.describe ImcPresenter do
  describe "#call" do
    let(:user) { create(:user, height: 1.70) }
    let(:diet) { create(:diet, user_id: user.id) }
    let(:weight) { create(:weight, value: 80, user_id: user.id) }
    let(:imc) { 27.68 }

    context "when imc is not valid" do
      let(:user) { create(:user, height: nil) }

      it "weight and height is nil" do
        expect(described_class.new(user).call).to eq(0)
      end

      it "weight is nil" do
        diet
        expect(described_class.new(user).call).to eq(0)
      end

      it "height is nil" do
        weight
        expect(described_class.new(user).call).to eq(0)
      end
    end

    context "when imc is valid" do
      it "weight and height exist" do
        diet
        weight
        expect(described_class.new(user).call).to eq(imc)
      end

      it "calculates correctly when weight is in lbs and height is in ft" do
        user_lbs_ft = create(:user, height: 5.58, height_unit: HEIGHTS::FT)
        create(:weight, value: 176.37, weight_unit: WEIGHTS::LBS, user: user_lbs_ft)
        expect(described_class.new(user_lbs_ft).call).to eq(27.68)
      end

      it "calculates correctly when height is in cm" do
        user_cm = create(:user, height: 170.0, height_unit: HEIGHTS::CM)
        create(:weight, value: 80.0, weight_unit: WEIGHTS::KG, user: user_cm)
        expect(described_class.new(user_cm).call).to eq(27.68)
      end
    end
  end
end
