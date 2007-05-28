class UsersOwnThings < ActiveRecord::Migration
  def self.up
    add_column    :things, :user_id, :integer
  end

  def self.down
    remove_column :things, :user_id
  end
end
