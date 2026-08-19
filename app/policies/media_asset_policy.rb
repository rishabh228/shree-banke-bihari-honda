# frozen_string_literal: true

class MediaAssetPolicy < ApplicationPolicy
  def index? = admin_user? || super_admin?
  def show? = admin_user? || super_admin?
  def create? = admin_user? || super_admin?
  def update? = admin_user? || super_admin?
  def destroy? = super_admin?

  class Scope < Scope
    def resolve = scope.all
  end
end
