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
      data: grouped_metrics(sport_workouts, sport),
      recent: sport_workouts.order(workout_date: :desc).limit(3)
    }
  end

  def self.metric_key(sport)
    WorkoutType::DISTANCE_SPORTS.include?(sport) ? 'workout.chart_distance' : 'workout.chart_duration'
  end

  def self.grouped_metrics(workouts, sport)
    metric = WorkoutType::DISTANCE_SPORTS.include?(sport) ? :distance : :duration
    workouts.order(workout_date: :asc).group(:workout_date).sum(metric).transform_values { |value| value.round(2) }
  end

  private_class_method :chart_for, :metric_key, :grouped_metrics
end
