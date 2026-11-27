# frozen_string_literal: true

class BmiPresenter
  def initialize(user)
    @user = user
  end

  def call
    return 0 if weight.nil? || height.nil?

    (weight / (height**2)).round(2)
  end

  private

  attr_reader :user

  def weight
    last_weight = RecentWeightPresenter.new(user).call
    return if last_weight.nil?

    UnitConverter.convert_weight_between(last_weight.value, last_weight.weight_unit, MeasurementUnits::WEIGHTS::KG)
  end

  def height
    return if user.height.nil?

    UnitConverter.convert_height_between(user.height, user.height_unit, MeasurementUnits::HEIGHTS::M)
  end
end
