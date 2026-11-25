# frozen_string_literal: true

# Heights in feet are typed and shown as feet and inches (5'9"), but stored as decimal feet.
module FeetAndInches
  INCHES_PER_FOOT = 12
  PATTERN = /\A\s*(?<feet>\d+)\s*(?:'|ft)\s*(?:(?<inches>\d+(?:\.\d+)?)\s*(?:"|in)?)?\s*\z/i

  module_function

  # Decimal feet for "5'9\"", "5' 9", "5ft 9in" or a plain number; nil when it is neither.
  def parse(text)
    match = PATTERN.match(text.to_s)
    return Float(text, exception: false) unless match

    match[:feet].to_i + (match[:inches].to_f / INCHES_PER_FOOT)
  end

  def display(decimal_feet)
    return if decimal_feet.nil?

    total_inches = (decimal_feet * INCHES_PER_FOOT).round(1)
    feet = (total_inches / INCHES_PER_FOOT).floor
    inches = (total_inches - (feet * INCHES_PER_FOOT)).round(1)
    "#{feet}'#{inches.to_s.delete_suffix('.0')}\""
  end
end
