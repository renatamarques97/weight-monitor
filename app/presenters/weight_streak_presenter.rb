# frozen_string_literal: true

class WeightStreakPresenter
  delegate :streak_days, :streak_weeks, :total_days, :total_weeks, to: :streak

  def initialize(user)
    @streak = StreakPresenter.new(user.weights, :weight_date)
  end

  private

  attr_reader :streak
end
