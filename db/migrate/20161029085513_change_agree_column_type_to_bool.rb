class ChangeAgreeColumnTypeToBool < ActiveRecord::Migration
  def change
    change_column :votes, :agree, :boolean
  end
end
