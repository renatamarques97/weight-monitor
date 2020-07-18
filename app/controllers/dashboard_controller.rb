class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @diets = Diet.all
    # @dates = WeightHelper::weighting_dates(current_user)
    # @weight_data = WeightHelper::weights(current_user)
  end
end
