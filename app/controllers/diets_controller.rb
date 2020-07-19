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
    @diet.meals.build
  end

  # POST /diets
  def create
    @diet = current_user.diets.build(diet_params)

    if @diet.save
      flash[:notice] = "Diet was successfully created."
      redirect_to(root_path)
    else
      render :new
    end
  end

  # PATCH/PUT /diets/1
  def update
    if @diet.update(diet_params)
      flash[:notice] = "Diet was successfully updated."
      redirect_to(root_path)
    else
      render :edit
    end
  end

  # DELETE /diets/1
  def destroy
    @diet.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Diet was successfully destroyed.' }
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
      meals_attributes: %i[schedule description meal_type _destroy]
    )
  end
end
