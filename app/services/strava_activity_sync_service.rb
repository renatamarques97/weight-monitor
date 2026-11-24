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

    activities(per_page).each do |activity|
      imported += import_activity(activity)
    end

    imported
  end

  private

  def activities(per_page)
    StravaApiService.new(@user).activities(per_page: per_page).reject do |activity|
      activity.fetch('id').nil?
    end
  end

  def import_activity(activity)
    workout = find_workout(activity)
    is_new = workout.new_record?
    workout.assign_attributes(attributes_for(activity))

    workout.save && is_new ? 1 : 0
  end

  def find_workout(activity)
    sport_type = map_sport(activity)
    workout_class = sport_type.to_s.camelize.constantize
    workout_class.where(user: @user).find_or_initialize_by(strava_activity_id: activity.fetch('id'))
  end

  def attributes_for(activity)
    {
      workout_type: map_sport(activity),
      workout_date: workout_date(activity),
      duration: workout_duration(activity),
      distance: workout_distance(activity),
      distance_unit: MeasurementUnits::DISTANCES::KM,
      calories: activity['calories']&.to_i,
      details: details_for(activity)
    }
  end

  def workout_date(activity)
    Time.zone.parse(activity.fetch('start_date_local')).to_date
  end

  def workout_duration(activity)
    (activity.fetch('moving_time', 0).to_f / 60.0).round(2)
  end

  def workout_distance(activity)
    distance = activity['distance'].to_f / 1000.0
    distance.round(2) if distance.positive?
  end

  def map_sport(activity)
    SPORT_TYPES.fetch(activity['sport_type'], SPORT_TYPES.fetch(activity['type'], :other))
  end

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
