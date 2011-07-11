class CreateExamUsers < ActiveRecord::Migration
  def self.up
    create_table :exam_users do |t|
      t.integer :examination_id, :null => false
      t.integer :user_id
      t.string :password
      t.boolean :user_affirm, :default => 0
      t.datetime :created_at
      t.integer :paper_id
      t.datetime :started_at
      t.datetime :submited_at
      t.datetime :ended_at
      t.boolean :is_submited, :default => 0
      t.boolean :open_to_user, :default => 0
      t.string :answer_sheet_url
   
    end
    add_index :exam_users,:examination_id
    add_index :exam_users,:user_id
    add_index :exam_users,:paper_id
  end

  def self.down
    drop_table :exam_users
  end
end
