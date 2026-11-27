# frozen_string_literal: true

class StravaActivitySyncService
  include StravaActivityDetailsMapper

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

    each_activity_page(per_page) do |page_activities|
      imported += import_page(page_activities)
    end

    imported
  end

  private

  def each_activity_page(per_page)
    page = 1

    loop do
      page_activities = activities(per_page: per_page, page: page)
      break if page_activities.empty?

      yield page_activities
      break if page_activities.length < per_page

      page += 1
    end
  end

  def import_page(page_activities)
    imported = 0

    page_activities.each do |activity|
      existing_workout = find_workout(activity)
      if existing_workout.persisted?
        update_existing_workout(existing_workout, activity)
        next
      end

      imported += import_activity(activity)
    end

    imported
  end

  def update_existing_workout(workout, activity)
    workout.assign_attributes(attributes_for(activity))
    workout.save
  end

  def activities(per_page:, page:)
    api = StravaApiService.new(@user)
    response = page == 1 ? api.activities(per_page: per_page) : api.activities(per_page: per_page, page: page)

    response.reject do |activity|
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
    existing = @user.workouts.find_by(strava_activity_id: activity.fetch('id'))
    return existing if existing

    sport_type = map_sport(activity)
    sport_type.to_s.camelize.constantize.find_or_initialize_by(
      user: @user,
      strava_activity_id: activity.fetch('id')
    )
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
end
