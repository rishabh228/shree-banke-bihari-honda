# frozen_string_literal: true

class BannerPolicy < ApplicationPolicy
  def index? = super_admin? || manager?
  def show? = super_admin? || manager?
  def create? = super_admin? || manager?
  def update? = super_admin? || manager?
  def destroy? = super_admin?

  class Scope < Scope
    def resolve = scope.all
  end
end
