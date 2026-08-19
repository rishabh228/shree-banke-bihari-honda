# frozen_string_literal: true

require "test_helper"

class NotificationBadgeTest < ActionDispatch::IntegrationTest
  include ActionCable::TestHelper

  setup do
    setup_billing_context
    @user.notifications.create!(title: "New enquiry")
  end

  test "unread count json updates the badge payload" do
    sign_in @user
    host! "localhost"
    get unread_count_admin_notifications_path,
        as: :json,
        headers: {
          "HTTP_USER_AGENT" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
        }

    assert_response :success
    assert_equal 1, response.parsed_body["count"]
  end

  test "mark all read broadcasts a zero unread count" do
    sign_in @user
    host! "localhost"

    assert_broadcast_on NotificationsChannel.broadcasting_for(@user), count: 0 do
      patch mark_all_read_admin_notifications_path, headers: browser_headers
    end

    assert_redirected_to admin_notifications_path
    assert_equal 0, @user.notifications.unread.count
  end

  private

  def browser_headers
    { "HTTP_USER_AGENT" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36" }
  end
end
