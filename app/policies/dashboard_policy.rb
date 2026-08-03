# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  def index?
    admin_user? || sales_executive? || service_advisor?
  end
end
