# frozen_string_literal: true

# Public on purpose: the sign-up form converts height before the user has an account.
# It only does arithmetic on the given params and never touches user data.
class UnitConversionsController < ApplicationController
  def convert
    return render json: { value: nil } if params[:value].blank?

    value = converted_value
    return render json: { error: 'Invalid conversion parameters' }, status: :bad_request if value.nil?

    render json: { value: value, display: display(value) }
  end

  private

  def converted_value
    type, from_unit, to_unit = params.values_at(:type, :from_unit, :to_unit)
    value = input_value
    return unless value&.finite? && UnitConverter.supports?(type, from_unit, to_unit)

    UnitConverter.convert(type, value, from_unit, to_unit)
  end

  # Heights in feet may be typed as feet and inches (5'9").
  def input_value
    return FeetAndInches.parse(params[:value]) if height_in_feet?(params[:from_unit])

    Float(params[:value], exception: false)
  end

  def display(value)
    height_in_feet?(params[:to_unit]) ? FeetAndInches.display(value) : value.to_s
  end

  def height_in_feet?(unit)
    params[:type] == MeasurementUnits::TYPES::HEIGHT && unit == MeasurementUnits::HEIGHTS::FT
  end
end
