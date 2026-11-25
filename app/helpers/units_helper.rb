# frozen_string_literal: true

# Lists always show measures in the signed-in user's preferred units, whatever unit
# each record was saved in. Forms keep the record's own unit (see unit_label_controller.js).
module UnitsHelper
  def unit_options(units)
    units.map { |unit| [t("units.#{unit}"), unit] }
  end

  def weight_in_preferred_unit(value, unit)
    preferred = current_user.weight_unit
    measure(UnitConverter.convert_weight_between(value, unit, preferred), preferred)
  end

  def distance_in_preferred_unit(value, unit)
    preferred = current_user.distance_unit
    measure(UnitConverter.convert_distance_between(value, unit, preferred), preferred)
  end

  def speed_in_preferred_unit(value, unit)
    preferred = current_user.distance_unit
    measure(UnitConverter.convert_speed_between(value, unit, preferred), "#{preferred}/h")
  end

  def pace_in_preferred_unit(workout)
    preferred = current_user.distance_unit
    distance = UnitConverter.convert_distance_between(workout.distance, workout.distance_unit, preferred)
    pace = PaceFormatter.call(workout.duration, distance)
    pace && "#{pace}/#{preferred}"
  end

  def height_field_value(user)
    return user.height_before_type_cast if user.errors.include?(:height)

    user.height_unit_ft? ? FeetAndInches.display(user.height) : user.height
  end

  def height_placeholder(unit)
    unit == MeasurementUnits::HEIGHTS::FT ? %(5'9") : unit
  end

  UNIT_PLACEHOLDER = '__unit__'

  # Data attributes for a label whose unit follows a unit select in the same form.
  def unit_label_data(key, translation_key)
    { unit_label_target: 'label', unit_label_key: key, unit_label_template: t(translation_key, unit: UNIT_PLACEHOLDER) }
  end

  def unit_select_data(key)
    { unit_label_target: 'select', unit_label_key: key, action: 'change->unit-label#update' }
  end

  private

  def measure(value, unit)
    return '-' if value.nil?

    "#{number_with_precision(value, precision: 2, strip_insignificant_zeros: true)} #{unit}"
  end
end
