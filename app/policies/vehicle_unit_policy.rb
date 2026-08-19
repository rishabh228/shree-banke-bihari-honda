# frozen_string_literal: true

class VehicleUnitPolicy < ApplicationPolicy
  def index? = sales_user?
  def show? = sales_user?
  def create? = sales_user?
  def update? = sales_user?
  def destroy? = super_admin? || manager?

  class Scope < Scope
    def resolve = scope.all
  end
end
