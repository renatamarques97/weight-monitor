# frozen_string_literal: true

class UnitConversionsController < ApplicationController
  before_action :authenticate_user!

  def convert
    return render json: { value: nil } if params[:value].blank?

    value = converted_value
    if value.nil?
      return render json: { error: 'Invalid conversion parameters' }, status: :bad_request
    end

    render json: { value: value }
  end

  private

  def converted_value
    value = Float(params[:value], exception: false)
    return unless valid_conversion?(value)

    method_name = "convert_#{params[:type]}_between"
    UnitConverter.public_send(method_name, value, params[:from_unit], params[:to_unit])
  end

  def valid_conversion?(value)
    units = units_for(params[:type])
    value&.finite? && units&.include?(params[:from_unit]) && units.include?(params[:to_unit])
  end

  def units_for(type)
    case type
    when MeasurementUnits::TYPES::HEIGHT then MeasurementUnits::HEIGHTS::ALL
    when MeasurementUnits::TYPES::WEIGHT then MeasurementUnits::WEIGHTS::ALL
    when MeasurementUnits::TYPES::DISTANCE, MeasurementUnits::TYPES::SPEED then MeasurementUnits::DISTANCES::ALL
    when MeasurementUnits::TYPES::TIME then MeasurementUnits::TIMES::ALL
    end
  end
end
