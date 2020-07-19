class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @diets = Diet.all
    @imc = ::ImcPresenter.new(current_user).call
    @weights = ::WeightQuery.weights(current_user)
  end
end
