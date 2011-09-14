class CreateUserBelieves < ActiveRecord::Migration
  def self.up
    create_table :user_believes do |t|
      t.integer :user_id
      t.integer :id
      t.date :created_at
      t.integer :belief
    end
    add_index :user_believes,:user_id
  end

  def self.down
    drop_table :user_believes
  end
end
