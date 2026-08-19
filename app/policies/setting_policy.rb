# frozen_string_literal: true

class SettingPolicy < ApplicationPolicy
  def show? = super_admin?
  def update? = super_admin?

  class Scope < Scope
    def resolve = scope.all
  end
end
