# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161113083537) do

  create_table "answers", force: :cascade do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "answer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "following_users", force: :cascade do |t|
    t.integer "follower_id"
    t.integer "following_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions_topics", force: :cascade do |t|
    t.integer "question_id"
    t.integer "topic_id"
  end

  create_table "topics", force: :cascade do |t|
    t.string "name"
    t.text   "description"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "password_hash"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_salt"
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "answer_id"
    t.boolean  "agree"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
