# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  validates :title, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  after_commit :broadcast_unread_count

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current)
  end

  def self.broadcast_unread_count_for(user)
    return if user.blank?

    NotificationsChannel.broadcast_to(user, { count: user.notifications.unread.count })
  end

  private

  def broadcast_unread_count
    self.class.broadcast_unread_count_for(user)
  end
end
