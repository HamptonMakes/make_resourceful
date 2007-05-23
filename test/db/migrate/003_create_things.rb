class CreateThings < ActiveRecord::Migration
  def self.up
    create_table :things do |t|
      t.column :name, :string
      t.column :awesome, :boolean
      t.column :person_id, :integer
    end
  end

  def self.down
    drop_table :things
  end
end
