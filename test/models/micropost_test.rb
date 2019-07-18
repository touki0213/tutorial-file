require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)  #サンプルユーザーとの紐付け
    @micropost = @user.microposts.build(content: "Lorem ipsum")  #micropostが有効かどうかのチェック
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end
 

  test "content should be present" do
    @micropost.content=""
    assert_not @micropost.valid?
  end

  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  test "order should be most recent first" do
    assert_equal microposts(:most_recent),Micropost.first #fixture内の(most_recent)と同じか検証
  end
end
