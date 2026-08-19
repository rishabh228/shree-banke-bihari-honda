# frozen_string_literal: true

require "test_helper"

class NotificationBroadcastTest < ActionCable::TestCase
  setup do
    setup_billing_context
  end

  test "creating a notification broadcasts the unread count" do
    assert_broadcast_on NotificationsChannel.broadcasting_for(@user), count: 1 do
      @user.notifications.create!(title: "New enquiry")
    end
  end

  test "marking a notification read broadcasts the remaining count" do
    note = @user.notifications.create!(title: "New enquiry")

    assert_broadcast_on NotificationsChannel.broadcasting_for(@user), count: 0 do
      note.mark_as_read!
    end
  end
end
