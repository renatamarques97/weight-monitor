# frozen_string_literal: true

class WorkoutQuery
  def self.chart_data(user, period_in_days = 30)
    start_date = period_in_days.days.ago.to_date
    target_distance_unit = user.distance_unit

    WorkoutType::MAPPING.keys.each_with_object({}) do |sport, result|
      sport_workouts = user.send(sport).where(workout_date: start_date..)
      recent_sport_workouts = sport_workouts.order(workout_date: :desc).limit(3)
      sport_workouts = sport_workouts.order(workout_date: :asc)

      if WorkoutType::DISTANCE_SPORTS.include?(sport)
        grouped_metrics = sport_workouts.each_with_object(Hash.new(0.0)) do |workout, hash|
          normalized = UnitConverter.convert_distance_between(workout.distance.to_f, workout.distance_unit, target_distance_unit).to_f

          hash[workout.workout_date] += normalized
        end

        translation_metric_key = 'workout.chart_distance'
      else
        grouped_metrics = sport_workouts.group(:workout_date).sum(:duration)
        translation_metric_key = 'workout.chart_duration'
      end

      grouped_metrics.transform_values! { |metric_value| metric_value.round(2) }

      result[sport] = {
        translation_metric_key: translation_metric_key,
        color: WorkoutType::COLORS[sport],
        data: grouped_metrics,
        recent: recent_sport_workouts
      }
    end
  end
end
