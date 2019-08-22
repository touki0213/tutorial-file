class User < ApplicationRecord
  has_many :microposts,#micropostモデルと関連付けてる
            dependent: :destroy  #ユーザーが削除した時マイクロポストも一緒に解除される

  has_many :active_relationships, class_name: "Relationship",  #二人のユーザーの関係
            foreign_key: "follower_id",  #「foreign_key」はdbの二つのテーブルを繋ぐとき用いる
            dependent: :destroy

  has_many :passive_relationships, class_name: "Relationship",
            foreign_key: "followed_id",
            dependent: :destroy

  has_many :following, through: :active_relationships, source: :followed  #対象のユーザーを取得している
  has_many :followers, through: :passive_relationships, source: :follower  

  has_many :from_messages, class_name: "Message", foreign_key: "from_id", dependent: :destroy
  has_many :to_messages, class_name: "Message", foreign_key: "to_id", dependent: :destroy
  has_many :sent_messages, through: :from_messages, source: :from
  has_many :received_messages, through: :to_messages, source: :to

  attr_accessor :remember_token, :activation_token, :reset_token  #「attr_accessor」仮想の属性を作成
  before_save   :downcase_email
  before_create :create_activation_digest
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true


  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token  #「self」の代入によってユーザーのremember_token属性が期待通りに設定される
    update_attribute(:remember_digest, User.digest(remember_token))  #「update_attribute」で記憶ダイジェストを更新
  end

 # トークンがダイジェストと一致したらtrueを返す
 def authenticated?(attribute, token)
  digest = send("#{attribute}_digest")
  return false if digest.nil?
  BCrypt::Password.new(digest).is_password?(token)
end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  #パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  #パスワード再設定のメールを送信
  def sent_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

    # パスワード再設定の期限が切れている場合はtrueを返す
    def password_reset_expired?
      reset_sent_at < 2.hours.ago
    end

     # ユーザーのステータスフィードを返す
    def feed
      following_ids = "SELECT followed_id FROM relationships
                      WHERE follower_id = :user_id"
      Micropost.where("user_id IN (#{following_ids})
                      OR user_id = :user_id", user_id: id)
    end                                       

      # ユーザーをフォローする
    def follow(other_user)
      following << other_user
    end

    # ユーザーをフォロー解除する
    def unfollow(other_user)
      active_relationships.find_by(followed_id: other_user.id).destroy
    end

    # 現在のユーザーがフォローしてたらtrueを返す
    def following?(other_user)
      following.include?(other_user)
    end

  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      self.email = email.downcase
    end

    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

    #他のuserにmessageを送る
    def send_message(other_user, room_id, content)
      from_messages.create!(to_id: other_user.id, room_id: room_id, content: content)
    end
end
