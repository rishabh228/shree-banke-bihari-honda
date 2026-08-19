# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    include Admin::PdfExportable
    include Admin::Ransackable

    layout "admin"

    before_action :authenticate_user!
    before_action :authorize_admin_access!
    before_action :load_unread_notifications_count

    private

    def load_unread_notifications_count
      @unread_notifications_count = current_user.notifications.unread.count
    end

    def authorize_admin_access!
      return if current_user.super_admin? || current_user.manager? ||
                current_user.sales_executive? || current_user.service_advisor?

      flash[:alert] = "Admin access required."
      redirect_to root_path
    end
  end
end
