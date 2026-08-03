# frozen_string_literal: true

class TestRidePolicy < ApplicationPolicy
  def index? = sales_user?
  def show? = sales_user?
  def create? = true
  def update? = sales_user?
  def destroy? = super_admin?

  class Scope < Scope
    def resolve = scope.all
  end
end
