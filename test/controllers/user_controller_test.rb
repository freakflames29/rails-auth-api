require "test_helper"

class UserControllerTest < ActionDispatch::IntegrationTest
  test "should get userInfo" do
    get user_userInfo_url
    assert_response :success
  end
end
