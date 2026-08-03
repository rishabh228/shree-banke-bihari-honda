# frozen_string_literal: true

class BikePolicy < ApplicationPolicy
  def index? = admin_user? || sales_user?
  def show? = admin_user? || sales_user?
  def create? = admin_user?
  def update? = admin_user?
  def destroy? = super_admin?
  def publish? = admin_user?
  def hide? = admin_user?

  class Scope < Scope
    def resolve = scope.all
  end
end
