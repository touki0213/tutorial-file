require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    @user = users(:michael)
    @other = users(:archer)
    log_in_as(@user)
  end

  test "following page" do
    get following_user_path(@user)
    assert_not @user.following.empty?  # ←これは 17行目を確認するテスト
    assert_match @user.following.count.to_s,response.body
    @user.following.each do |user|
      assert_select "a[href=?]",user_path(user)
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    assert_not @user.followers.empty?  # ←これは 26行目を確認するテスト
    assert_match @user.followers.count.to_s,response.body
    @user.followers.each do |user|
      assert_select "a[href=?]",user_path(user)
    end
  end

  # #relationshipに対してPOSTリクエストをお送り、フォローされたユーザーが一人増えたことを確認
  # test "should follow a user the standard way" do
  #   assert_difference '@user.following.count',1 do
  #     post relationships_path, params: {followed_id: @other.id}
  #   end
  # end

  # #「xhr」をtrueにして、Ajaxでリクエストを発行するように変わる
  # test "should follow a user with Ajax" do
  #   assert_difference '@user.following.count', 1 do
  #     post relationships_path, xhr: true ,params:{followed_id: @other.id}
  #   end
  # end

  # #user_idとrelationship_idを使ってDELETEリクエストわ送信し、フォローしている数が一つ減ることを確認
  # test "should unfollow a user the stamdard way" do
  #   @user.follow(@other)
  #   relationship = @user.active_relationships.find_by(followed_id: @other.id)
  #   assert_difference '@user.following.count',-1 do
  #     delete relationship_path(relationship)
  #   end
  # end

  # #「xhr」をtrueにして、Ajaxでリクエストを発行するように変わる
  # test "should unfollow a user with Ajax" do
  #   @user.follow(@other)
  #   relationship = @user.active_relationships.find_by(followed_id: @other.id)
  #   assert_difference '@user.following.count',-1 do
  #     delete relationship_path(relationship), xhr: true
  #   end
  # end
end


 