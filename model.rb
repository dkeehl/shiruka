require 'sinatra/activerecord'
require 'sinatra'
require 'bcrypt'

set :database, {adapter: 'sqlite3', database: 'shiruka.sqlite3'}

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
end

class FollowingUser < ActiveRecord::Base
  belongs_to :follower, class_name: 'User'
  belongs_to :following, class_name: "User"
end
