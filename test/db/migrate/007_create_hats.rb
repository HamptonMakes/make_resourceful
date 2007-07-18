class CreateHats < ActiveRecord::Migration
  def self.up
    create_table :hats do |t|
      t.column :style, :string
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :hats
  end
end
