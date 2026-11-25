# frozen_string_literal: true

class WorkoutQuery
  def self.chart_data(user, period_in_days = 30)
    start_date = period_in_days.days.ago.to_date

    WorkoutType::MAPPING.keys.index_with do |sport|
      chart_for(user, sport, start_date)
    end
  end

  def self.chart_for(user, sport, start_date)
    sport_workouts = user.public_send(sport).where(workout_date: start_date..)

    {
      translation_metric_key: metric_key(sport),
      color: WorkoutType::COLORS[sport],
      data: grouped_metrics(sport_workouts, sport, user.distance_unit),
      recent: sport_workouts.order(workout_date: :desc).limit(3)
    }
  end

  def self.metric_key(sport)
    distance_sport?(sport) ? 'workout.chart_distance' : 'workout.chart_duration'
  end

  def self.grouped_metrics(workouts, sport, distance_unit)
    workouts = workouts.order(workout_date: :asc)
    metrics = if distance_sport?(sport)
                distance_by_date(workouts, distance_unit)
              else
                workouts.group(:workout_date).sum(:duration)
              end

    metrics.transform_values { |value| value.round(2) }
  end

  # Sums distances per day in the user's preferred unit, converting each stored unit first.
  def self.distance_by_date(workouts, distance_unit)
    workouts.group(:workout_date, :distance_unit).sum(:distance)
            .each_with_object(Hash.new(0.0)) do |((date, unit), total), totals|
      totals[date] += UnitConverter.convert_distance_between(total, unit, distance_unit)
    end
  end

  def self.distance_sport?(sport)
    WorkoutType::DISTANCE_SPORTS.include?(sport)
  end

  private_class_method :chart_for, :metric_key, :grouped_metrics, :distance_by_date, :distance_sport?
end
