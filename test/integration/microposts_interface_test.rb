require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:jin)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination' # assert the presence of the pagination class
    assert_select 'input[type=submit]' # ???????????????????????????????????????
    # invalid submission
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: {
        micropost: {
          content: ""
        }
      }
    end
    assert_select 'div#error_explanation'
    # valid submisssion
    content = "This is the valid content for a valid micropost."
    picture = fixture_file_upload('test/fixtures/files/rails.png', 'image/png')
    assert_difference('Micropost.count', 1) do
      post microposts_path, params: {
        micropost: {
          content: content,
          picture: picture
        }
      }
    end
    assert assigns(:micropost).picture? # how does rails know this is that micropost?
    assert_redirected_to root_url
    follow_redirect!
    # delete post
    assert_select 'a', text: 'delete' # find and assert the presence of the delete link.
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference("Micropost.count", -1) do
      delete micropost_path(first_micropost)
    end
    # visit different user (no delete links)
    get user_path(users(:sponge))
    assert_select 'a', text: 'delete', count: 0
  end

  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count.to_s} microposts", response.body
    # user with zero microposts.
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    assert_match "0 microposts", response.body
    other_user.microposts.create!(content: "A micropost")
    get root_path
    assert_match "1 micropost", response.body
  end

end
