class CreatePapers < ActiveRecord::Migration
  def self.up
    create_table :papers do |t|
      t.integer :category_id, :null => false
      t.string :title
      t.integer :creater_id, :null => false
      t.string :description
      t.integer :total_score, :default => 0
      t.integer :total_question_num, :default => 0
      t.boolean :is_used, :default => 0
      t.string :paper_url

      t.timestamps
    end
    add_index :papers,:category_id
  end

  def self.down
    drop_table :papers
  end
end
