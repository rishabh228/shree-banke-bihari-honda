# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :authenticate_user!
    before_action :authorize_admin_access!

    private

    def authorize_admin_access!
      return if current_user.super_admin? || current_user.manager? ||
                current_user.sales_executive? || current_user.service_advisor?

      flash[:alert] = "Admin access required."
      redirect_to root_path
    end
  end
end
