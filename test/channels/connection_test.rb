# frozen_string_literal: true

require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  setup do
    setup_billing_context
  end

  test "accepts a signed-in user" do
    connect env: { "warden" => WardenUserStub.new(@user) }

    assert_equal @user, connection.current_user
  end

  test "rejects an anonymous connection" do
    assert_reject_connection { connect env: { "warden" => WardenUserStub.new(nil) } }
  end

  class WardenUserStub
    def initialize(user)
      @user = user
    end

    def user
      @user
    end
  end
end
