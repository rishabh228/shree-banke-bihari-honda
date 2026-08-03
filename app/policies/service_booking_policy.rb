# frozen_string_literal: true

class ServiceBookingPolicy < ApplicationPolicy
  def index? = service_user?
  def show? = service_user?
  def create? = true
  def update? = service_user?
  def destroy? = super_admin?

  class Scope < Scope
    def resolve = scope.all
  end
end
