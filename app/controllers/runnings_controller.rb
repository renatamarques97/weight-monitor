# frozen_string_literal: true

class RunningsController < ApplicationController
  before_action :authenticate_user!

  # GET /runnings/new
  def new
    @running = Running.new
  end

  # POST /runnings
  def create
    @running = current_user.runnings.build(running_params)

    if @running.save
      flash[:notice] = "Running was successfully created."
      redirect_to(root_path)
    else
      render :new
    end
  end

  private

  def running_params
    params.require(:running).permit(:duration, :distance, :avg_pace, :running_date, :user_id)
  end
end
