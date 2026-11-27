# frozen_string_literal: true

class StreakPresenter
  def initialize(records, date_column)
    @recorded_dates = records.distinct.pluck(date_column).compact
  end

  def streak_days
    return 0 if recorded_dates.empty?

    cursor = active_day_cursor
    count = 0

    while recorded_dates.include?(cursor)
      count += 1
      cursor -= 1.day
    end

    count
  end

  def streak_weeks
    return 0 if recorded_weeks.empty?

    cursor = active_week_cursor
    count = 0

    while recorded_weeks.include?(cursor)
      count += 1
      cursor -= 1.week
    end

    count
  end

  def total_days
    recorded_dates.length
  end

  def total_weeks
    recorded_weeks.length
  end

  private

  attr_reader :recorded_dates

  def active_day_cursor
    today = Date.current
    recorded_dates.include?(today) ? today : today - 1.day
  end

  def active_week_cursor
    this_week = Date.current.beginning_of_week(:monday)
    recorded_weeks.include?(this_week) ? this_week : this_week - 1.week
  end

  def recorded_weeks
    @recorded_weeks ||= recorded_dates.map { |date| date.beginning_of_week(:monday) }.uniq
  end
end
