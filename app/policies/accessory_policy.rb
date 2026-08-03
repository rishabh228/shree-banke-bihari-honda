# frozen_string_literal: true

class AccessoryPolicy < ApplicationPolicy
  def index? = admin_user?
  def show? = admin_user?
  def create? = admin_user?
  def update? = admin_user?
  def destroy? = super_admin?

  class Scope < Scope
    def resolve = scope.all
  end
end
