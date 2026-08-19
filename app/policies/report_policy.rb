# frozen_string_literal: true

class ReportPolicy < ApplicationPolicy
  def index?
    admin_user?
  end

  def tally_export?
    index?
  end
end
