class DietsController < ApplicationController
  before_action :set_diet, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /diets
  def index
    @diets = Diet.all
  end

  # GET /diets/new
  def new
    @diet = Diet.new
    @diet.build_meal
  end

  # POST /diets
  def create
    @diet = Diet.new(diet_params)

    respond_to do |format|
      if @diet.save
        format.html { redirect_to @diet, notice: 'Diet was successfully created.' }
        format.json { render :show, status: :created, location: @diet }
      else
        format.html { render :new }
        format.json { render json: @diet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /diets/1
  def update
    respond_to do |format|
      if @diet.update(diet_params)
        format.html { redirect_to @diet, notice: 'Diet was successfully updated.' }
        format.json { render :show, status: :ok, location: @diet }
      else
        format.html { render :edit }
        format.json { render json: @diet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /diets/1
  def destroy
    @diet.destroy
    respond_to do |format|
      format.html { redirect_to diets_url, notice: 'Diet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_diet
    @diet = Diet.find(params[:id])
  end

  def diet_params
    params.require(:diet)
    .permit(
      :start_date,
      :end_date,
      :initial_weight,
      :target_weight,
      :height,
      :user_id,
      meal_attributes: %i[schedule description meal_type _destroy]
    )
  end
end
