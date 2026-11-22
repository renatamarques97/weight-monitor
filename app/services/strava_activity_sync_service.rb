# frozen_string_literal: true

class StravaActivitySyncService
  SPORT_TYPES = {
    'Run' => :running,
    'VirtualRun' => :running,
    'TrailRun' => :running,
    'Ride' => :cycling,
    'VirtualRide' => :cycling,
    'EBikeRide' => :cycling,
    'Walk' => :walking,
    'Hike' => :walking,
    'Swim' => :swimming,
    'WeightTraining' => :weightlifting,
    'Yoga' => :yoga,
    'Workout' => :weightlifting
  }.freeze

  def initialize(user)
    @user = user
  end

  def sync(per_page: 30)
    imported = 0

    StravaApiService.new(@user).activities(per_page: per_page).each do |activity|
      next if activity.fetch('id').nil?

      sport_type = map_sport(activity)
      workout_class = sport_type.to_s.camelize.constantize
      workout = workout_class.where(user: @user).find_or_initialize_by(
        strava_activity_id: activity.fetch('id')
      )
      is_new = workout.new_record?

      workout.assign_attributes(attributes_for(activity))
      imported += 1 if workout.save && is_new
    end

    imported
  end

  private

  def attributes_for(activity)
    sport_type = map_sport(activity)
    distance = activity['distance'].to_f / 1000.0

    {
      workout_type: sport_type,
      workout_date: Time.zone.parse(activity.fetch('start_date_local')).to_date,
      duration: (activity.fetch('moving_time', 0).to_f / 60.0).round(2),
      distance: distance.positive? ? distance.round(2) : nil,
      calories: activity['calories']&.to_i,
      details: details_for(activity, sport_type)
    }
  end

  def map_sport(activity)
    SPORT_TYPES.fetch(activity['sport_type'], SPORT_TYPES.fetch(activity['type'], :other))
  end

  def details_for(activity, sport_type)
    details = {}

    case sport_type
    when :running
      details[:avg_pace] = calculate_pace(activity)
    when :cycling
      details[:avg_speed] = (activity['average_speed'].to_f * 3.6).round(1).presence
    when :walking
      details[:steps] = activity['total_elevation_gain'].to_i if activity['total_elevation_gain'].to_i.positive?
    when :swimming
      details[:laps] = activity['lap_count'].to_i if activity['lap_count'].to_i.positive?
    end

    details.compact
  end

  def calculate_pace(activity)
    duration_minutes = activity.fetch('moving_time', 0).to_f / 60.0
    distance_km = activity['distance'].to_f / 1000.0

    (duration_minutes / distance_km).round(2) if distance_km.positive?
  end
end
