# frozen_string_literal: true

class WorkoutAdherencePresenter
  def initialize(user)
    @user = user
  end

  def state
    return :not_set unless plan
    return :no_plan if sessions.empty?

    :tracked
  end

  def adherence_percent
    return nil unless state == :tracked

    completed = sessions.count { |session| session.workout.present? }
    ((completed.to_f / sessions.length) * 100).round.clamp(0, 100)
  end

  private

  attr_reader :user

  def plan
    @plan ||= user.current_workout_plan
  end

  def sessions
    @sessions ||= plan ? plan.sessions.includes(:workout).order(:session_date).to_a : []
  end
end
