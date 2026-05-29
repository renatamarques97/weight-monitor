require 'rails_helper'

RSpec.describe WorkoutQuery do
  describe ".chart_data" do
    let(:user) { create(:user) }

    it "returns chart metadata and data for all workout types" do
      result = described_class.chart_data(user, 30)

      expect(result.keys).to contain_exactly(*WorkoutType::MAPPING.keys)
      expect(result[:running][:color]).to eq(WorkoutType::COLORS[:running])
      expect(result[:running][:translation_metric_key]).to eq('workout.chart_distance')
      expect(result[:yoga][:translation_metric_key]).to eq('workout.chart_duration')
    end

    it "aggregates distance for distance sports and duration for others" do
      running_date = 2.days.ago.to_date
      yoga_date = 1.day.ago.to_date
      create(:running, user: user, workout_date: running_date, distance: 4.0, duration: 25)
      create(:running, user: user, workout_date: running_date, distance: 6.5, duration: 40)
      create(:yoga, user: user, workout_date: yoga_date, duration: 45)
      create(:yoga, user: user, workout_date: yoga_date, duration: 35)

      result = described_class.chart_data(user, 30)

      expect(result[:running][:data][running_date]).to eq(10.5)
      expect(result[:yoga][:data][yoga_date]).to eq(80.0)
    end

    it "returns only 3 recent workouts ordered by date desc" do
      4.times do |index|
        create(:cycling, user: user, workout_date: index.days.ago.to_date)
      end

      result = described_class.chart_data(user, 30)

      expect(result[:cycling][:recent].size).to eq(3)
      expect(result[:cycling][:recent].map(&:workout_date)).to eq([
        0.days.ago.to_date,
        1.day.ago.to_date,
        2.days.ago.to_date
      ])
    end
  end
end
