class AddTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :name
      t.text :description
    end

    create_table :questions_topics do |t|
      t.belongs_to :question
      t.belongs_to :topic
    end
  end
end
