class CreateExamRaters < ActiveRecord::Migration
  def self.up
    create_table :exam_raters do |t|
      t.datetime :created_at
      t.string :name
      t.string :mobilephone
      t.string :email
      t.string :author_code
      t.integer :examination_id, :null => false
      
    end
      add_index :exam_raters,:examination_id
      add_index :exam_raters,:author_code
  end

  def self.down
    drop_table :exam_raters
  end
end
