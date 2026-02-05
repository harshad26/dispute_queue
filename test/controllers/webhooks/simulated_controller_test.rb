require "test_helper"

class Webhooks::SimulatedControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get webhooks_simulated_create_url
    assert_response :success
  end

  test "should get new" do
    get webhooks_simulated_new_url
    assert_response :success
  end
end
