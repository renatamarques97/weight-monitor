# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StreakPresenter do
  let(:user) { create(:user) }

  it 'calculates consecutive day streaks and unique active days' do
    create(:weight, user: user, weight_date: Date.current)
    create(:weight, user: user, weight_date: 1.day.ago.to_date)

    streak = described_class.new(user.weights, :weight_date)

    expect(streak.streak_days).to eq(2)
    expect(streak.total_days).to eq(2)
  end

  it 'allows a day streak to start yesterday' do
    create(:running, user: user, workout_date: 1.day.ago.to_date)
    create(:running, user: user, workout_date: 2.days.ago.to_date)

    streak = described_class.new(user.workouts, :workout_date)

    expect(streak.streak_days).to eq(2)
  end

  it 'breaks streaks when a day or week is missing' do
    create(:weight, user: user, weight_date: 2.days.ago.to_date)

    streak = described_class.new(user.weights, :weight_date)

    expect(streak.streak_days).to eq(0)
  end

  it 'calculates consecutive weeks and unique active weeks' do
    create(:running, user: user, workout_date: Date.current)
    create(:running, user: user, workout_date: 1.week.ago.to_date)

    streak = described_class.new(user.workouts, :workout_date)

    expect(streak.streak_weeks).to eq(2)
    expect(streak.total_weeks).to eq(2)
  end

  it 'exposes weight and workout streaks through User' do
    create(:weight, user: user, weight_date: Date.current)
    create(:running, user: user, workout_date: Date.current)

    expect(user.weight_streak.streak_days).to eq(1)
    expect(user.workout_streak.streak_days).to eq(1)
  end
end
