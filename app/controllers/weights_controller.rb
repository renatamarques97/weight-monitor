# frozen_string_literal: true

class WeightsController < ApplicationController
  before_action :authenticate_user!

  # GET /weights
  def index
    weights = current_user.weights.order(weight_date: :desc, created_at: :desc)
    @pagy, @weights = pagy(weights, limit: 20)
  end

  # GET /weights/new
  def new
    @weight = Weight.new(weight_unit: current_user.weight_unit)
  end

  # POST /weights
  def create
    @weight = current_user.weights.build(weight_params)

    if @weight.save
      flash[:notice] = t('weight.created')
      redirect_to(root_path)
    else
      render :new
    end
  end

  private

  def weight_params
    params.expect(weight: %i[value weight_unit weight_date])
  end
end
