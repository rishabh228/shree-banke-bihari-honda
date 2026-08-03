# frozen_string_literal: true

class SalePolicy < ApplicationPolicy
  def index? = sales_user?
  def show? = sales_user?
  def create? = sales_user?
  def update? = sales_user?
  def destroy? = super_admin? || manager?
  def transition? = sales_user?
  def export_pdf? = index?
  def quotation_pdf? = show?

  class Scope < Scope
    def resolve
      return scope.all if user.super_admin? || user.manager?

      scope.where(sales_executive: user)
    end
  end
end
