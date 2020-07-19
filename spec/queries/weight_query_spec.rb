require 'rails_helper'

RSpec.describe WeightQuery do
  describe ".weights" do
    let!(:user) { create(:user) }
    let!(:weight_kg) { 70.0 }
    let!(:weight) { create(:weight, kg: weight_kg, user_id: user.id) }
    let!(:expected_return) do
      { Date.current=>weight_kg }
    end

    it "valid parameters" do
      expect(described_class.weights(user)).to eq(expected_return)
    end
  end
end
