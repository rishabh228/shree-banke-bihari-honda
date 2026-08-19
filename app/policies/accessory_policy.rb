# frozen_string_literal: true

class AccessoryPolicy < ApplicationPolicy
  def index? = admin_user? || sales_user? || service_user?
  def show? = index?
  def create? = admin_user?
  def update? = admin_user?
  def destroy? = super_admin?
  def bill_on_counter? = index?

  class Scope < Scope
    def resolve = scope.all
  end
end
