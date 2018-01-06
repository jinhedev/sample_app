require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest

  include ApplicationHelper

  def setup
    @user = users(:jin)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name) # should be ohjinnyboy ohjinnyboy | Ruby on ...
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar' # checks for an img tag with class gravatar inside of a top-level heading tag h1
    assert_match @user.microposts.count.to_s, response.body # return the receiver as an array of string
    assert_select 'div.pagination'
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body # search the whole html page for match to the actual content attribute of a micropost instance
    end
  end

end
