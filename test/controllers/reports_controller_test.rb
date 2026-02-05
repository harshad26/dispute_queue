require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "should get money_math" do
    get reports_money_math_url
    assert_response :success
  end

  test "should get time_zone" do
    get reports_time_zone_url
    assert_response :success
  end

  test "should get daily_volume" do
    get reports_daily_volume_url
    assert_response :success
  end

  test "should get time_to_decision" do
    get reports_time_to_decision_url
    assert_response :success
  end
end
