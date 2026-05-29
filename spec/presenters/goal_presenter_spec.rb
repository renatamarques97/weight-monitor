require 'rails_helper'

RSpec.describe GoalPresenter do
  describe "#achieved" do
    let(:user) { create(:user) }
    let(:valid_diet) { create(:diet, target_weight: 80, user: user) }
    let(:valid_weight) { create(:weight, kg: 80, user: user) }

    let(:diet) { create(:diet, target_weight: 80, user: user) }
    let(:weight) { create(:weight, kg: 90, user: user) }

    context "when goal was not achieved" do
      it "weight and target weight don't match" do
        diet
        weight
        expect(described_class.new(user).achieved?).to eq(false)
      end

      it "weight is nil" do
        diet
        expect(described_class.new(user).achieved?).to eq(false)
      end

      it "target weight is nil" do
        weight
        expect(described_class.new(user).achieved?).to eq(false)
      end
    end

    context "when goal was achieved" do
      it "weight and target weight match" do
        valid_diet
        valid_weight
        expect(described_class.new(user).achieved?).to eq(true)
      end
    end
  end
end
