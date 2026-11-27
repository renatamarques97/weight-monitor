# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user|
      user.permit(:name, :email, :password, :password_confirmation, :height,
                  :account_type, :professional_type, :country_code,
                  :professional_credential, :professional_registration_number,
                  *unit_preference_attributes)
    end

    devise_parameter_sanitizer.permit(:account_update) do |user|
      user.permit(:name, :email, :password, :current_password, :height,
                  :account_type, :professional_type, :country_code,
                  :professional_credential, :professional_registration_number,
                  *unit_preference_attributes)
    end
  end

  def unit_preference_attributes
    %i[weight_unit distance_unit height_unit]
  end

  private

  def render_not_found
    respond_to do |format|
      format.html { render 'errors/not_found', status: :not_found }
      format.any  { head :not_found }
    end
  end
end
