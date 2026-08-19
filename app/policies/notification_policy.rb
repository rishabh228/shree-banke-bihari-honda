# frozen_string_literal: true

class NotificationPolicy < ApplicationPolicy
  def index?
    staff_user?
  end

  def mark_read?
    record.user_id == user.id
  end

  def mark_all_read?
    staff_user?
  end

  def unread_count?
    index?
  end

  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end

  private

  def staff_user?
    user.super_admin? || user.manager? || user.sales_executive? || user.service_advisor?
  end
end
