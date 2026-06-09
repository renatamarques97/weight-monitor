# frozen_string_literal: true

require 'ruby-units'

class UnitConverter
  include MeasurementUnits

  def self.convert_weight_between(value, from_unit, to_unit)
    self.convert(value, from_unit, to_unit)
  end

  def self.convert_distance_between(value, from_unit, to_unit)
    self.convert(value, from_unit, to_unit)
  end

  def self.convert_height_between(value, from_unit, to_unit)
    self.convert(value, from_unit, to_unit)
  end

  def self.convert_speed_between(value, from_unit, to_unit)
    self.convert(value, from_unit, to_unit)
  end

  def self.convert_time_between(value, from_unit, to_unit)
    self.convert(value, from_unit, to_unit)
  end

  private

  def self.convert(value, from_unit, to_unit, precision: 2) 
    return nil if value.nil?

    return value.round(precision) if from_unit.to_s == to_unit.to_s

    RubyUnits::Unit.new("#{value} #{from_unit}").convert_to(to_unit.to_s).scalar.to_f.round(precision)
  end
end
