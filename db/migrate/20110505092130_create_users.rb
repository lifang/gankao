class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :username
      t.string :mobilephone
      t.string :email
      t.string :address
      t.string :salt
      t.string :encrypted_password
      t.integer :status, :default => 0
      t.string :active_code
      
      t.timestamps
      
    end
    add_index :users,:name
    add_index :users,:email
    add_index :users,:status
  end

  def self.down
    drop_table :users
  end
end
