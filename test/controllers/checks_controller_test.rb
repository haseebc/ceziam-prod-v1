require "test_helper"

class ChecksControllerTest < ActionDispatch::IntegrationTest
  test "should get full_report" do
    get checks_full_report_url
    assert_response :success
  end
end
