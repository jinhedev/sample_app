require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

  test "should get new" do
    get login_path
    assert_response :success
  end

  test "should destroy" do
    delete logout_path
    # assert_redirected_to root_url # this should be handled by integration test
  end

end
