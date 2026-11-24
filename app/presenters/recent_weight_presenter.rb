# frozen_string_literal: true

class RecentWeightPresenter
  def initialize(user)
    @user = user
  end

  def call
    recent_weight
  end

  def trend_30_days
    weights = weights_from_last_30_days
    oldest = weights.first
    latest = weights.last

    return nil unless trend_endpoints_present?(oldest, latest)

    trend_between(oldest, latest)
  end

  private

  attr_reader :user

  def recent_weight
    user.weights.order(weight_date: :desc, created_at: :desc).first
  end

  def weights_from_last_30_days
    user.weights
        .where(weight_date: 30.days.ago.to_date..Date.current)
        .order(weight_date: :asc, created_at: :asc)
  end

  def trend_endpoints_present?(oldest, latest)
    oldest.present? && latest.present? && oldest.id != latest.id
  end

  # Difference in the user's preferred unit, so records saved in other units still compare.
  def trend_between(oldest, latest)
    (in_preferred_unit(latest) - in_preferred_unit(oldest)).round(1)
  end

  def in_preferred_unit(weight)
    UnitConverter.convert_weight_between(weight.value, weight.weight_unit, user.weight_unit)
  end
end
