# frozen_string_literal: true

# Running pace as minutes and seconds per distance unit, e.g. 5'46".
module PaceFormatter
  module_function

  def call(duration_in_minutes, distance)
    return if duration_in_minutes.blank? || distance.blank? || distance.zero?

    minutes, seconds = (duration_in_minutes * 60 / distance).round.divmod(60)
    "#{minutes}'#{seconds.to_s.rjust(2, '0')}\""
  end
end
