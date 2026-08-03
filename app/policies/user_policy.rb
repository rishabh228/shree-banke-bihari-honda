# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index? = super_admin?
  def show? = super_admin?
  def create? = super_admin?
  def update? = super_admin?
  def destroy? = super_admin?

  class Scope < Scope
    def resolve = scope.all
  end
end
