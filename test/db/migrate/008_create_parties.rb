class CreateParties < ActiveRecord::Migration
  def self.up
    create_table :parties do |t|
      t.column :name, :string
    end
    
    create_table :parties_people, :id => false do |t|
      t.column :party_id, :integer
      t.column :person_id, :integer
    end
  end

  def self.down
    drop_table :parties
  end
end
