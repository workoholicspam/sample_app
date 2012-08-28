# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation

  has_many        :microposts, 
                                  dependent:    :destroy

  has_many        :relationships, 
                                  foreign_key:  "follower_id", 
                                  dependent:    :destroy  

  has_many        :followed_users, 
                                  through:      :relationships, 
                                  source:       :followed
  
  has_many        :reverse_relationships,
                                  foreign_key:  "followed_id",
                                  class_name:   "Relationship",
                                  dependent:    :destroy

  has_many        :followers,     
                                  through:      :reverse_relationships, 
                                  source:       :follower


  has_many        :mentions,
                                  foreign_key:  "mention_user_id",
                                  dependent:    :destroy

  has_many        :mention_microposts,
                                  through:      :mentions,
                                  source:       :micropost

  has_secure_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  #MATCH leading '@'
  #CAPTURE anything (after the '@' variable) that begins with a letter, followed by any combination of letters, numbers, underscore, hyphens
  VALID_ATNAME_REGEX = /\B@([a-z][a-z0-9_\-]*)/i
  #CAPTURE anything that begins with a letter, followed by any combination of letters, numbers, underscore, hyphens
  VALID_NAME_REGEX   = /\A[a-z][a-z0-9_\-]*\z/i


  before_save { self.email.downcase! }
  before_save :create_remember_token
  
  validates :name,                  presence:     true,  
                                    format:     { with: VALID_NAME_REGEX },
                                    length:     { maximum: 50 },
                                    uniqueness: { case_sensitive: false   }



  validates :email,                 presence:     true,  
                                    format:     { with: VALID_EMAIL_REGEX },
                                    uniqueness: { case_sensitive: false   }

  validates :password,              length:     { minimum: 6              }

  validates :password_confirmation, presence:     true

  def feed
    Micropost.from_users_followed_by(self)
  end

  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end

  def self.get_users_from_text(text)
    names = parse_for_names(text)
    users = where("LOWER(name) in (?)", names) #case insensitive search by names
  end

  protected
  
    def self.parse_for_names(text)
      capture_user_name_regex = VALID_ATNAME_REGEX 

      text.downcase.scan(capture_user_name_regex).flatten #using '(' & ')' to scan yields a nested array, so we flatten to get 1-dimensional array
    end

  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end
