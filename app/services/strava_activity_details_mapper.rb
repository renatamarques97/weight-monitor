# frozen_string_literal: true

module StravaActivityDetailsMapper
  private

  def details_for(activity)
    case map_sport(activity)
    when :running then running_details(activity)
    when :cycling then cycling_details(activity)
    when :walking then walking_details(activity)
    when :swimming then swimming_details(activity)
    else {}
    end
  end

  def running_details(activity)
    { avg_pace: calculate_pace(activity) }.compact
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

  def calculate_pace(activity)
    duration_minutes = activity.fetch('moving_time', 0).to_f / 60.0
    distance_km = activity['distance'].to_f / 1000.0

    (duration_minutes / distance_km).round(2) if distance_km.positive?
  end
end
