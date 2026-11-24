# frozen_string_literal: true

# Linear conversions between the units the app supports. Every factor is the size of
# one unit expressed in the base unit of its dimension (kg, km, m and s).
class UnitConverter
  include MeasurementUnits

  PRECISION = 2

  DISTANCE_FACTORS = { DISTANCES::KM => 1.0, DISTANCES::MI => 1.609344 }.freeze

  FACTORS = {
    TYPES::WEIGHT => { WEIGHTS::KG => 1.0, WEIGHTS::LBS => 0.45359237 }.freeze,
    TYPES::DISTANCE => DISTANCE_FACTORS,
    # Speeds are always per hour, so only the distance part changes.
    TYPES::SPEED => DISTANCE_FACTORS,
    TYPES::HEIGHT => { HEIGHTS::M => 1.0, HEIGHTS::CM => 0.01, HEIGHTS::FT => 0.3048 }.freeze,
    TYPES::TIME => { TIMES::SECONDS => 1.0, TIMES::MINUTES => 60.0 }.freeze
  }.freeze

  class << self
    def convert_weight_between(value, from_unit, to_unit)
      convert(TYPES::WEIGHT, value, from_unit, to_unit)
    end

    def convert_distance_between(value, from_unit, to_unit)
      convert(TYPES::DISTANCE, value, from_unit, to_unit)
    end

    def convert_height_between(value, from_unit, to_unit)
      convert(TYPES::HEIGHT, value, from_unit, to_unit)
    end

    def convert_speed_between(value, from_unit, to_unit)
      convert(TYPES::SPEED, value, from_unit, to_unit)
    end

    def convert_time_between(value, from_unit, to_unit)
      convert(TYPES::TIME, value, from_unit, to_unit)
    end

    def convert(type, value, from_unit, to_unit)
      return if value.nil?
      return value.round(PRECISION) if from_unit.to_s == to_unit.to_s

      factors = FACTORS.fetch(type.to_s)
      (value * factors.fetch(from_unit.to_s) / factors.fetch(to_unit.to_s)).round(PRECISION)
    end

    def supports?(type, from_unit, to_unit)
      factors = FACTORS[type.to_s]
      return false if factors.nil?

      factors.key?(from_unit.to_s) && factors.key?(to_unit.to_s)
    end
  end
end
