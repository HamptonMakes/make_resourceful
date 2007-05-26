class CreateProperties < ActiveRecord::Migration
  def self.up
    create_table :properties do |t|
      t.column :thing_id, :integer
      t.column :name, :string
    end
  end

  def self.down
    drop_table :properties
  end
end
