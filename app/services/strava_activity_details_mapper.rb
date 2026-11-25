# frozen_string_literal: true

module StravaActivityDetailsMapper
  private

  # Running pace is not imported: Running#calculate_average_pace derives it on save.
  def details_for(activity)
    case map_sport(activity)
    when :cycling then cycling_details(activity)
    when :walking then walking_details(activity)
    when :swimming then swimming_details(activity)
    else {}
    end
  end

  def cycling_details(activity)
    speed = (activity['average_speed'].to_f * 3.6).round(1)
    { avg_speed: speed.presence }.compact
  end

  def walking_details(activity)
    elevation = activity['total_elevation_gain'].to_i
    elevation.positive? ? { steps: elevation } : {}
  end

  def swimming_details(activity)
    laps = activity['lap_count'].to_i
    { laps: laps.presence }.compact
  end
end
