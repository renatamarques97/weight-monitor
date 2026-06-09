# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |user| user.permit(:name, :email, :password, :password_confirmation, :height, :weight_unit, :distance_unit, :height_unit)}

    devise_parameter_sanitizer.permit(:account_update) { |user| user.permit(:name, :email, :password, :current_password, :height, :weight_unit, :distance_unit, :height_unit)}
  end
end
