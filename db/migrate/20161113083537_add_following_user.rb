class AddFollowingUser < ActiveRecord::Migration
  def change
    create_table :following_users do |t|
      t.belongs_to :follower
      t.belongs_to :following
    end
  end
end
