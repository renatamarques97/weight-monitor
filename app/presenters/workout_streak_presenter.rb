# frozen_string_literal: true

class WorkoutStreakPresenter
  def initialize(user)
    @streak = StreakPresenter.new(user.workouts, :workout_date)
  end

  delegate :streak_days, :streak_weeks, :total_days, :total_weeks, to: :streak

  private

  attr_reader :streak
end
