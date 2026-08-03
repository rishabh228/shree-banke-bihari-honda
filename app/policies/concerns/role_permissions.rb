# frozen_string_literal: true

module RolePermissions
  extend ActiveSupport::Concern

  def super_admin? = user&.super_admin?
  def manager? = user&.manager?
  def sales_executive? = user&.sales_executive?
  def service_advisor? = user&.service_advisor?

  def admin_user? = super_admin? || manager?
  def sales_user? = super_admin? || manager? || sales_executive?
  def service_user? = super_admin? || manager? || service_advisor?
end
