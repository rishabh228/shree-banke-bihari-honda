# frozen_string_literal: true

require "test_helper"

class NotificationsChannelTest < ActionCable::Channel::TestCase
  setup do
    setup_billing_context
    stub_connection current_user: @user
  end

  test "subscribes to the signed-in user stream" do
    subscribe

    assert subscription.confirmed?
    assert_has_stream_for @user
  end
end
