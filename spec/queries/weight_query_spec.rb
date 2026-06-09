require 'rails_helper'

RSpec.describe WeightQuery do
  describe ".weights" do
    let(:user) { create(:user) }

    it "returns the latest Weight record for each date" do
      date = Date.current
      create(:weight, user: user, weight_date: date, value: 79.1)
      create(:weight, user: user, weight_date: date, value: 78.6)
      create(:weight, user: user, weight_date: date - 1.day, value: 80.0)

      result = described_class.weights(user)
      expect(result[date].value).to eq(78.6)
      expect(result[date - 1.day].value).to eq(80.0)
    end

    it "filters by period in days" do
      create(:weight, user: user, weight_date: 40.days.ago.to_date, value: 82.0)
      create(:weight, user: user, weight_date: 10.days.ago.to_date, value: 79.0)

      result = described_class.weights(user, 30)

      expect(result.keys).to contain_exactly(10.days.ago.to_date)
    end
  end

  describe ".weights_for_chart" do
    let(:user) { create(:user, weight_unit: WEIGHTS::KG) }

    it "normalizes mixed-unit records to user preferred unit" do
      date = Date.current
      # Record saved in kg
      create(:weight, user: user, weight_date: date - 1.day, value: 70.0, weight_unit: WEIGHTS::KG)
      # Record saved in lbs
      create(:weight, user: user, weight_date: date, value: 154.32, weight_unit: WEIGHTS::LBS)

      result = described_class.weights_for_chart(user, 30)

      # kg record stays as 70.0 kg
      expect(result[date - 1.day]).to eq(70.0)
      # lbs record (154.32 lbs) converts to ~70.0 kg
      expect(result[date]).to eq(70.0)
    end

    it "filters by period in days" do
      create(:weight, user: user, weight_date: 40.days.ago.to_date, value: 82.0, weight_unit: WEIGHTS::KG)
      create(:weight, user: user, weight_date: 10.days.ago.to_date, value: 79.0, weight_unit: WEIGHTS::KG)

      result = described_class.weights_for_chart(user, 30)

      expect(result.keys).to contain_exactly(10.days.ago.to_date)
      expect(result.values).to contain_exactly(79.0)
    end
  end
end
