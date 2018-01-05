require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:jin)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    # invalid email.
    post password_resets_path, params: {
      password_reset: {
        email: ""
      }
    }
    assert_not flash.empty?
    assert_template 'password_resets/new'
    # valid email.
    post password_resets_path, params: {
      password_reset: {
        email: @user.email
      }
    }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest # why not equal?? @user.reload.reset_digest supposed to be nil?
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty? # should show something like "Email has been sent with instructions"
    assert_redirected_to root_url
    # password reset form.
    user = assigns(:user)
    # wrong email.
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    # inactive user.
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # right email, wrong token.
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # right email, right token.
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    # invalid password & confirmation.
    patch password_reset_path(user.reset_token), params: {
      email: user.email,
      user: {
        password: "foobarbaz",
        password_confirmation: "foobarboo"
      }
    }
    assert_select 'div#error_explanation'
    # empty password.
    patch password_reset_path(user.reset_token), params: {
      email: user.email,
      user: {
        password: "",
        password_confirmation: ""
      }
    }
    assert_select 'div#error_explanation'
    # valid password & confirmation.
    patch password_reset_path(user.reset_token), params: {
      email: user.email,
      user: {
        password: "foobarbaz",
        password_confirmation: "foobarbaz"
      }
    }
    assert is_logged_in?
    assert_not flash.empty? # password has been reset.
    assert_redirected_to user
  end

  test "expired token" do
    get new_password_reset_path
    post password_resets_path, params:  {
      password_reset: {
        email: @user.email
      }
    }
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token), params: {
      email: @user.email,
      user: {
        password: "foobarbarz",
        password_confirmation: "foobarbaz"
      }
    }
    assert_response :redirect
    follow_redirect!
    assert_match("expired".downcase, response.body.downcase)
  end

end
