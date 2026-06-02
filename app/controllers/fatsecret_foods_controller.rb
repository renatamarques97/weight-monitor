class FatsecretFoodsController < ApplicationController
  def index
    query = params[:q]
    return render json: [] if query.blank?

    service = FatSecretApiService.new

    response = service.search_foods(query)
    if response['error'].present?
      return render json: { error: response['error']['message'] }, status: :unprocessable_entity
    end

    foods = response.dig('foods', 'food') || response.dig('foods_search', 'results', 'food') || []
    foods = [foods] if foods.is_a?(Hash)
    render json: foods
  end

  def show
    service = FatSecretApiService.new
    food = service.get_food(params[:id])
    render json: food
  end
end
