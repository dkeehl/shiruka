#require 'sinatra/activerecord'
require 'active_record'
require 'bcrypt'


class User < ActiveRecord::Base
  has_many :answers
  has_many :comments
  has_many :following_users, foreign_key: :follower_id, dependent: :destroy
  has_many :followings, through: :following_users 
  has_many :follower_users,
            class_name: 'FollowingUser', foreign_key: :following_id, dependent: :destroy
  has_many :followers, through: :follower_users

  validates :name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :password_hash, presence: true
  validates :password_salt, presence: true

  attr_readonly :password_salt, :password_hash

  def password=(password)
    salt = BCrypt::Engine.generate_salt
    self.password_salt = salt
    self.password_hash = BCrypt::Engine.hash_secret(password, salt)
  end

  def self.auth(email, password)
    user = self.find_by(email: email)

    return nil unless user

    hash = BCrypt::Engine.hash_secret(password, user.password_salt)
    hash == user.password_hash ? user : nil
  end
end

class Question < ActiveRecord::Base
  has_many :answers, dependent: :destroy
  has_many :questions_topics, dependent: :destroy
  has_many :topics, through: :questions_topics

  validates :name, presence: true
end

class Comment < ActiveRecord::Base
  belongs_to :answer
  belongs_to :user
end

class Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :question
  has_many   :comments, dependent: :destroy
  has_many   :votes, dependent: :destroy

  def self.search(key_word)
    where("content LIKE ?", "%#{ key_word }%")
  end
end

class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :answer
end

class Topic < ActiveRecord::Base
  has_many :questions_topics, dependent: :destroy
  has_many :questions, through: :questions_topics
  
  validates :name, presence: true
end

class QuestionsTopic < ActiveRecord::Base
  belongs_to :topic
  belongs_to :question

  validates :topic_id, presence: true
  validates :question_id, presence: true

  class << self
    def update_topics(q_id, topics)
      old_topics = []
      ot = where(question_id: q_id)
      ot.each do |r|
        old_topics << r.topic_id
      end

      add, del = diff_topic(old_topics, topics)
      
      #delete
      del.each { |id| ot.find_by(topic_id: id).destroy }
      #add new
      add.each do |id|
        create question_id: q_id, topic_id: id
      end
    end
      
    private
    def diff_topic(old_topics, new_topics)
      del = old_topics - new_topics
      add = new_topics - old_topics
      return add, del
    end
  end
end

class FollowingUser < ActiveRecord::Base
  belongs_to :follower, class_name: 'User'
  belongs_to :following, class_name: "User"
end
