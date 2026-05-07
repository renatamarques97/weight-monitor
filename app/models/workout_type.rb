# frozen_string_literal: true

module WorkoutType
  RUNNING = 0
  WALKING = 1
  CYCLING = 2
  SWIMMING = 3
  WEIGHTLIFTING = 4
  YOGA = 5
  SOCCER = 6
  BASKETBALL = 7
  TENNIS = 8
  MARTIAL_ARTS = 9
  OTHER = 10

  MAPPING = {
    running: RUNNING,
    walking: WALKING,
    cycling: CYCLING,
    swimming: SWIMMING,
    weightlifting: WEIGHTLIFTING,
    yoga: YOGA,
    soccer: SOCCER,
    basketball: BASKETBALL,
    tennis: TENNIS,
    martial_arts: MARTIAL_ARTS,
    other: OTHER
  }.freeze

  ICONS = {
    running: 'fa-road',
    walking: 'fa-street-view',
    cycling: 'fa-bicycle',
    swimming: 'fa-tint',
    weightlifting: 'fa-anchor',
    yoga: 'fa-leaf',
    soccer: 'fa-futbol-o',
    basketball: 'fa-dribbble',
    tennis: 'fa-circle-o',
    martial_arts: 'fa-hand-rock-o',
    other: 'fa-heartbeat'
  }.freeze

  COLORS = {
    other: '#6366f1',
    running: '#f59e0b',
    walking: '#10b981',
    cycling: '#3b82f6',
    swimming: '#06b6d4',
    weightlifting: '#ef4444',
    yoga: '#8b5cf6',
    soccer: '#22c55e',
    basketball: '#f97316',
    tennis: '#eab308',
    martial_arts: '#ec4899'
  }.freeze

  # Sports that track distance
  DISTANCE_SPORTS = %i[running walking cycling swimming].freeze

  # Sports that are duration-only (no distance)
  DURATION_ONLY_SPORTS = %i[other weightlifting yoga soccer basketball tennis martial_arts].freeze

  def self.t(type)
    I18n.t("workout.types.#{type}")
  end
end
