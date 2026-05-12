require 'rails_helper'

RSpec.describe WeightQuery do
  describe ".weights" do
    let(:user) { create(:user) }

    it "returns latest weight for each date" do
      date = Date.current
      create(:weight, user: user, weight_date: date, kg: 79.1)
      create(:weight, user: user, weight_date: date, kg: 78.6)
      create(:weight, user: user, weight_date: date - 1.day, kg: 80.0)

      expect(described_class.weights(user)).to eq({
        date - 1.day => 80.0,
        date => 78.6
      })
    end

    it "filters by period in days" do
      create(:weight, user: user, weight_date: 40.days.ago.to_date, kg: 82.0)
      create(:weight, user: user, weight_date: 10.days.ago.to_date, kg: 79.0)

      result = described_class.weights(user, 30)

      expect(result.keys).to contain_exactly(10.days.ago.to_date)
      expect(result.values).to contain_exactly(79.0)
    end
  end
end
