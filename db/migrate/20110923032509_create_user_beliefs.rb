class CreateUserBeliefs < ActiveRecord::Migration
  def self.up
    create_table :user_beliefs do |t|
      t.integer :user_id
      t.integer :id
      t.date :created_at
      t.integer :belief
    end
    add_index :user_beliefs,:user_id
  end

  def self.down
    drop_table :user_beliefs
  end
end
