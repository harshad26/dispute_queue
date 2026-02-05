require "test_helper"

class Webhooks::DisputesControllerTest < ActionDispatch::IntegrationTest
  test "should create webhook event and enqueue job" do
    payload = {
      "id" => "evt_test_001",
      "type" => "charge.dispute.created",
      "data" => {
        "object" => {
          "id" => "dp_test_001",
          "charge" => "ch_test_001",
          "amount" => 5000,
          "currency" => "usd",
          "status" => "needs_response"
        }
      }
    }

    assert_difference "WebhookEvent.count", 1 do
      post webhooks_disputes_url, params: payload.to_json, headers: { "Content-Type" => "application/json" }
    end

    assert_response :ok

    webhook_event = WebhookEvent.last
    assert_equal "evt_test_001", webhook_event.external_id
    assert_equal "charge.dispute.created", webhook_event.event_type
  end

  test "should handle duplicate webhooks idempotently" do
    payload = {
      "id" => "evt_duplicate_001",
      "type" => "charge.dispute.created",
      "data" => {
        "object" => {
          "id" => "dp_dup_001",
          "charge" => "ch_dup_001",
          "amount" => 3000,
          "currency" => "eur",
          "status" => "needs_response"
        }
      }
    }

    # First request
    post webhooks_disputes_url, params: payload.to_json, headers: { "Content-Type" => "application/json" }
    assert_response :ok

    # Duplicate request
    assert_no_difference "WebhookEvent.count" do
      post webhooks_disputes_url, params: payload.to_json, headers: { "Content-Type" => "application/json" }
    end

    assert_response :ok
  end

  test "should reject invalid JSON" do
    post webhooks_disputes_url, params: "invalid json", headers: { "Content-Type" => "application/json" }
    assert_response :bad_request
  end

  test "should reject missing required fields" do
    payload = {
      "id" => "evt_invalid_001",
      "type" => "charge.dispute.created",
      "data" => {
        "object" => {
          "id" => "dp_invalid_001"
          # Missing: charge, amount, currency, status
        }
      }
    }

    post webhooks_disputes_url, params: payload.to_json, headers: { "Content-Type" => "application/json" }
    assert_response :unprocessable_entity
  end
end
