# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MealDiaryStreakPresenter do
  let(:user) { create(:user) }
  let(:presenter) { described_class.new(user) }

  it 'returns no streak without meal diary records' do
    expect(presenter.streak_weeks).to eq(0)
    expect(presenter.total_weeks).to eq(0)
  end

  it 'counts consecutive calendar weeks with records' do
    create(:meal_diary, user: user, diary_date: Date.current)
    create(:meal_diary, user: user, diary_date: 1.week.ago.to_date)

    expect(presenter.streak_weeks).to eq(2)
  end

  it 'counts total unique calendar weeks with records' do
    create(:meal_diary, user: user, diary_date: Date.current)
    create(:meal_diary, user: user, diary_date: 3.weeks.ago.to_date)

    expect(presenter.total_weeks).to eq(2)
  end

  it 'allows a streak to start in the previous week' do
    create(:meal_diary, user: user, diary_date: 1.week.ago.to_date)
    create(:meal_diary, user: user, diary_date: 2.weeks.ago.to_date)

    expect(presenter.streak_weeks).to eq(2)
  end
end
