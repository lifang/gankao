class CreateUserRoleRelations < ActiveRecord::Migration
  def self.up
    create_table :user_role_relations do |t|
      t.integer :role_id, :null => false
      t.integer :user_id, :null => false

    end
    add_index :user_role_relations,:role_id
    add_index :user_role_relations,:user_id
  end

  def self.down
    drop_table :user_role_relations
  end
end
