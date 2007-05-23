class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table 'users' do |t|
      t.column :email, :string
      t.column :password, :string
      t.column :first_name, :string
      t.column :last_name, :string
    end
  end

  def self.down
    drop_table 'users'
  end
end
