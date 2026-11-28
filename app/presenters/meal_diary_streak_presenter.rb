# frozen_string_literal: true

class MealDiaryStreakPresenter
  delegate :streak_days, :streak_weeks, :total_days, :total_weeks, to: :streak

  def initialize(user)
    @streak = StreakPresenter.new(user.meal_diaries, :diary_date)
  end

  private

  attr_reader :streak
end
