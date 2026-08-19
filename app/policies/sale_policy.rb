# frozen_string_literal: true

class SalePolicy < ApplicationPolicy
  def index? = sales_user?
  def show? = sales_user?
  def create? = sales_user?
  def update? = sales_user?
  def destroy? = super_admin? || manager?
  def transition? = sales_user?
  def export_pdf? = index?
  def quotation_pdf? = show?
  def issue_invoice? = update?
  def invoice_pdf? = show?
  def cancel_invoice? = update?
  def credit_note_pdf? = show?
  def create_receipt? = update?
  def destroy_receipt? = update?
  def receipt_pdf? = show?
  def delivery_challan_pdf? = show?
  def form21_pdf? = show?
  def form22_pdf? = show?
  def gate_pass_pdf? = show?
  def capture_irn? = update?
  def allot_chassis? = update?

  class Scope < Scope
    def resolve
      return scope.all if user.super_admin? || user.manager?

      scope.where(sales_executive: user)
    end
  end
end
