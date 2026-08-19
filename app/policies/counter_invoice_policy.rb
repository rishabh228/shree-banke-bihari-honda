# frozen_string_literal: true

class CounterInvoicePolicy < ApplicationPolicy
  def index? = staff?
  def show? = staff?
  def create? = staff?
  def update? = staff?
  def destroy? = admin_user?
  def issue? = update?
  def invoice_pdf? = show?
  def capture_irn? = update?
  def cancel_invoice? = update?
  def credit_note_pdf? = show?

  class Scope < Scope
    def resolve = scope.all
  end

  private

  def staff?
    sales_user? || service_user?
  end
end
