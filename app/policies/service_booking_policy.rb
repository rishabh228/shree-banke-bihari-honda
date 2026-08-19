# frozen_string_literal: true

class ServiceBookingPolicy < ApplicationPolicy
  def index? = service_user?
  def show? = service_user?
  def create? = true
  def update? = service_user?
  def destroy? = super_admin?
  def admin_create? = service_user? || sales_user?
  def job_card_pdf? = show?
  def issue_workshop_invoice? = update?
  def workshop_invoice_pdf? = show?
  def manage_job_card? = update?

  class Scope < Scope
    def resolve = scope.all
  end
end
