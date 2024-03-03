# frozen_string_literal: true

class WeightsController < ApplicationController
  before_action :authenticate_user!

  # GET /weights/new
  def new
    @weight = Weight.new
  end

  # POST /weights
  def create
    @weight = current_user.weights.build(weight_params)

    if @weight.save
      flash[:notice] = "Weight was successfully created."
      redirect_to(root_path)
    else
      render :new
    end
  end

  private

  def weight_params
    params.require(:weight).permit(:kg, :weight_date, :user_id)
  end
end
