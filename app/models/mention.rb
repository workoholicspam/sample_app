class Mention < ActiveRecord::Base
  attr_accessible :mention_user_id

  belongs_to :mention_user, class_name: "User"
  belongs_to :micropost

  validates :mention_user_id, presence: true
  validates :micropost_id,    presence: true
end
