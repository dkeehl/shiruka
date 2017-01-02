class CreateDb < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :password
      t.string :email
      t.timestamps
    end
    
    create_table :questions do |t|
      t.string :name
      t.text   :description
      t.references :user
      t.timestamps
    end

    create_table :answers do |t|
      t.text :content
      t.belongs_to :user
      t.belongs_to :question
      t.timestamps
    end

    create_table :comments do |t|
      t.text :content
      t.belongs_to :user
      t.belongs_to :answer
      t.timestamps
    end

    create_table :votes do |t|
      t.belongs_to :user
      t.belongs_to :answer
      t.binary     :agree
      t.timestamps
    end
  end
end
