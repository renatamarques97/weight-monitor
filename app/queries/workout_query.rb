# frozen_string_literal: true

class WorkoutQuery
  def self.chart_data(user, period_in_days = 30)
    start_date = period_in_days.days.ago.to_date

    WorkoutType::MAPPING.keys.each_with_object({}) do |sport, result|
      sport_workouts = user.send(sport).where(workout_date: start_date..)
      recent_sport_workouts = sport_workouts.order(workout_date: :desc).limit(3)

      sport_workouts = sport_workouts.order(workout_date: :asc)

      if WorkoutType::DISTANCE_SPORTS.include?(sport)
        grouped_metrics = sport_workouts.group(:workout_date).sum(:distance)

        translation_metric_key = 'workout.chart_distance'
      else
        grouped_metrics = sport_workouts.group(:workout_date).sum(:duration)
        translation_metric_key = 'workout.chart_duration'
      end

      grouped_metrics = grouped_metrics.transform_values { |value| value.round(2) }

      result[sport] = {
        translation_metric_key: translation_metric_key,
        color: WorkoutType::COLORS[sport],
        data: grouped_metrics,
        recent: recent_sport_workouts
      }
    end
  end
end
