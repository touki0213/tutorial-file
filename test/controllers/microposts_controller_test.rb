require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    @micropost = microposts(:orange)
  end

  test "should redirect create when not logged in" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: {micropost: {contest: "Lorem ipsum"}}
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy for wrong micropost" do  #自分以外のユーザーのマイクロポストは削除をしようとすると、
  log_in_as(users(:michael))                             #適切にリダイレクトされることを確認する
  micropost = microposts(:ants)
  assert_no_difference 'Micropost.count' do
    delete micropost_path(micropost)
  end
    assert_redirected_to root_url
  end
end
