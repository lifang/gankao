class CreateExaminations < ActiveRecord::Migration
  def self.up
    create_table :examinations do |t|
      t.string :title
      t.integer :creater_id, :null => false
      t.string :description
      t.boolean :is_score_open, :default => 0
      t.boolean :is_paper_open, :default => 0
      t.string :exam_password1
      t.string :exam_password2
      t.datetime :start_at_time
      t.datetime :start_end_time
      t.integer :exam_time
      t.boolean :is_published, :default => 0
      
      t.timestamps
    end
    add_index :examinations,:creater_id
    add_index :examinations,:is_score_open
    add_index :examinations,:is_paper_open
  end

  def self.down
    drop_table :examinations
  end
end
