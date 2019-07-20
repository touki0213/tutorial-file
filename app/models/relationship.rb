class Relationship < ApplicationRecord
    belongs_to :follower, class_name: "User"  #フォローされているユーザー
    belongs_to :followed, class_name: "User"  #フォローしているユーザー
    validates  :follower, presence: true
    validates  :followed, presence: true
end
