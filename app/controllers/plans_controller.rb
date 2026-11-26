# frozen_string_literal: true

class PlansController < ApplicationController
  def index
    @plans = plans_catalog
  end

  private

  def plans_catalog
    [
      {
        key: :free,
        price: '$0',
        period: nil,
        featured: false,
        features: %i[tracking strava_no ai_no]
      },
      {
        key: :premium_monthly,
        price: '$12',
        period: :month,
        featured: false,
        features: %i[tracking strava ai]
      },
      {
        key: :premium_semiannual,
        price: '$60',
        period: :six_months,
        featured: true,
        features: %i[tracking strava ai]
      },
      {
        key: :premium_annual,
        price: '$108',
        period: :year,
        featured: false,
        features: %i[tracking strava ai]
      },
      {
        key: :professional,
        price: '$29',
        period: :month,
        featured: false,
        features: %i[tracking strava ai professional_tools]
      }
    ]
  end
end
