require 'rails_helper'

RSpec.describe ImcPresenter do
  describe "#call" do
    let(:user) { create(:user) }
    let(:diet) { create(:diet, height: 1.70, user_id: user.id) }
    let(:weight) { create(:weight, kg: 80, user_id: user.id) }
    let(:imc) { 27.68 }

    context "when imc is not valid" do
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
    end
  end
end
