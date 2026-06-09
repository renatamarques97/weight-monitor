# frozen_string_literal: true

class UnitConversionsController < ApplicationController
  before_action :authenticate_user!

  def convert
    render json: { value: perform_conversion }
  rescue StandardError => e
    Rails.logger.error("Unit conversion error: #{e.message}")
    render json: { value: nil }
  end

  private

  def perform_conversion
    return if params[:value].blank?

    convert_value(
      params[:value].to_f,
      params[:from_unit],
      params[:to_unit],
      params[:type]
    )
  end

  def convert_value(value, from_unit, to_unit, type)
    return unless TYPES::ALL.include?(type)

    method_name = "convert_#{type}_between"
    UnitConverter.public_send(method_name, value, from_unit, to_unit)
  end
end
