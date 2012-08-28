class Micropost < ActiveRecord::Base
  after_create      :create_mentions!
  attr_accessible   :content
  belongs_to        :user
  has_many          :mentions,      dependent: :destroy
  has_many          :mention_users, through:   :mentions
  validates         :user_id,       presence:   true
  validates         :content,       presence:   true,
                                    length:   { maximum: 140 }
  default_scope     order:          'microposts.created_at DESC'

  def self.from_users_followed_by(user)
    user_ids = user.followed_user_ids << user.id
    micropost_ids = Mention.uniq.where(mention_user_id: user_ids).pluck(:micropost_id)
    
    where("user_id in (?) OR id in (?)", user_ids, micropost_ids)
  end

  def create_mentions!
    users = User.get_users_from_text(content)
    users.reduce([]) { |list, user| list << self.mentions.create!(mention_user_id: user.id) }
  end

end
