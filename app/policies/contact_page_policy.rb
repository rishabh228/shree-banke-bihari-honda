# frozen_string_literal: true

class ContactPagePolicy < ApplicationPolicy
  def edit?
    contact_editor?
  end

  def update?
    contact_editor?
  end

  private

  def contact_editor?
    user.super_admin? || user.manager?
  end
end
