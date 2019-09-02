class Micropost < ActiveRecord::Base
  has_many :likes, dependent: :destroy
  has_many :iine_users, through: :likes, source: :user

  belongs_to :user  #userモデルと関連付けてる、対応するユーザーを特定する
  
  default_scope -> {order(created_at: :desc)}  #新しい投稿から古い投稿の順に並ばせる
  mount_uploader :picture, PictureUploader  #「mount_uploader」画像と関連づけるメソッド
  validates :user_id, presence: true  #user_id の存在性
  validates :content, presence: true, length: {maximum:140}  #content の存在性。140文字の制限
  validate  :picture_size

    #マイクロポストをいいねする
    def iine(user)
      likes.create(user_id: user.id)
    end
  
    #マイクロポストのいいねを解除する
    def uniine(user)
      likes.find_by(user_id: user.id).destroy
    end
  
    #現在のユーザーがいいねしてたらtrueを返す
    def iine?(user)
      iine_users.include?(user)
    end

  private

  #アップロードされた画像のサイズをバリデーションする
  def picture_size
    if picture.size > 5.megabytes  #上限5MBで、それを超えたらerrorメッセージを表示させる
      errors.add(:picture, "shouldnbe less than 5MB")
    end
  end


end