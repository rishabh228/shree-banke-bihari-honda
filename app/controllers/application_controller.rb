# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit::Authorization

  allow_browser versions: :modern

  layout :set_layout

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :load_settings

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  after_action :apply_see_other_on_mutation_redirect, if: :mutation_redirect?

  helper_method :current_settings

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :role ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  def load_settings
    @current_settings = Setting.instance
  end

  def current_settings
    @current_settings
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path, status: :see_other)
  end

  def mutation_redirect?
    response.redirect? && !request.get? && !request.head?
  end

  def apply_see_other_on_mutation_redirect
    response.status = 303 if response.status == 302
  end

  def after_sign_in_path_for(resource)
    resource.super_admin? || resource.manager? || resource.sales_executive? || resource.service_advisor? ? admin_root_path : root_path
  end

  def set_layout
    return "devise" if devise_controller?

    "application"
  end
end
