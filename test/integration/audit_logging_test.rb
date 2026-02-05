require "test_helper"

class AuditLoggingTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one) # Assuming 'one' is an admin or has permissions
    @dispute = disputes(:one)
  end

  test "logs user login and logout" do
    assert_difference "AuditLog.count", 1 do
      post session_url, params: { email_address: @user.email_address, password: "password" }
    end
    assert_equal "user.login", AuditLog.last.action
    assert_equal @user, AuditLog.last.user

    assert_difference "AuditLog.count", 1 do
      delete session_url
    end
    assert_equal "user.logout", AuditLog.last.action
  end

  test "logs dispute status change" do
    post session_url, params: { email_address: @user.email_address, password: "password" }

    assert_difference "AuditLog.count", 1 do
      patch dispute_url(@dispute), params: { transition: "won" }
    end
    assert_equal "dispute.resolved_won", AuditLog.last.action
    assert_equal @dispute, AuditLog.last.target
  end
end
