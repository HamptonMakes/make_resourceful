class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.column :name, :string
      t.column :age, :integer
    end
  end

  def self.down
    drop_table :people
  end
end
