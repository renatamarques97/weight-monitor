# frozen_string_literal: true

class RecentWeightPresenter
  def initialize(user)
    @user = user
  end

  def call
    recent_weight&.kg
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

  def trend_between(oldest, latest)
    (latest.kg - oldest.kg).round(1)
  end
end
