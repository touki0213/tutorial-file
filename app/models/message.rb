class Message < ApplicationRecord
    belongs_to :from, class_name: "User"
    belongs_to :to, class_name: "User"

    default_scope -> {order(created_at: :asc)}

    validates :from_id, presence: true
    validates :to_id, presence: true
    validates :room_id, presence: true
    validates :content, presence: true, length:  {maximum: 50}

    def Message.recent_in_room(room_id)
        where(room_id: room_id).last(500)
    end
end
