require "test_helper"

class DisputeTest < ActiveSupport::TestCase
  test "reopen! updates status and saves reason" do
    dispute = disputes(:one)
    dispute.update!(status: :closed_lost)

    reason = "Customer provided new evidence"
    dispute.reopen!(reason)

    assert dispute.open?
    assert_equal reason, dispute.reopen_reason
  end
end
