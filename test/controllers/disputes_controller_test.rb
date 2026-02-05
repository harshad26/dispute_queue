require "test_helper"

class DisputesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @admin.update!(role: :admin)
    @reviewer = users(:two)
    @reviewer.update!(role: :reviewer)
    @dispute = disputes(:one)
  end

  test "should redirect index when not logged in" do
    get disputes_path
    assert_redirected_to new_session_path
  end

  test "should get index when logged in" do
    post session_path, params: { email_address: @admin.email_address, password: "password" }
    get disputes_path
    assert_response :success
  end

  test "read_only cannot update dispute" do
    user = users(:two)
    user.update!(role: :read_only)
    post session_path, params: { email_address: user.email_address, password: "password" }

    patch dispute_path(@dispute), params: { transition: "won" }
    assert_redirected_to dispute_path(@dispute)
    follow_redirect!
    assert_match "not authorized", response.body
  end

  test "admin can reopen dispute" do
    post session_path, params: { email_address: @admin.email_address, password: "password" }

    @dispute.update!(status: :closed_lost)
    patch dispute_path(@dispute), params: { transition: "reopen", reopen_reason: "Mistake" }

    assert @dispute.reload.open?
    assert_equal "Mistake", @dispute.reopen_reason
  end

  test "reviewer cannot reopen dispute" do
    post session_path, params: { email_address: @reviewer.email_address, password: "password" }

    @dispute.update!(status: :closed_lost)
    patch dispute_path(@dispute), params: { transition: "reopen", reopen_reason: "Mistake" }

    assert @dispute.reload.closed_lost?
    assert_equal "Only admins can reopen disputes.", flash[:alert]
  end
end
