# frozen_string_literal: true

class PlansController < ApplicationController
  PLANS_CATALOG = [
    { key: :free, price: '$0', period: nil, featured: false,
      features: %i[tracking strava_no ai_no].freeze }.freeze,
    { key: :premium_monthly, price: '$12', period: :month, featured: false,
      features: %i[tracking strava ai].freeze }.freeze,
    { key: :premium_semiannual, price: '$60', period: :six_months, featured: true,
      features: %i[tracking strava ai].freeze }.freeze,
    { key: :premium_annual, price: '$108', period: :year, featured: false,
      features: %i[tracking strava ai].freeze }.freeze,
    { key: :professional, price: '$29', period: :month, featured: false,
      features: %i[tracking strava ai professional_tools].freeze }.freeze
  ].freeze

  def index
    @plans = PLANS_CATALOG
  end
end
