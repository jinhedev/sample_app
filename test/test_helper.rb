require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper

  # returns tue if a test user is logged in
  def is_logged_in?
    !session[:user_id].nil?
  end

  # log in as a particular user.
  def log_in_as(user)
    session[:user_id] = user.id
  end

end

class ActionDispatch::IntegrationTest

  # log in as a particular user.
  def log_in_as(user, password: 'password000', remember_me: '1')
    post login_path, params: {
      session: {
        email: user.email,
        password: password,
        remember_me: remember_me
      }
    }
  end

end
