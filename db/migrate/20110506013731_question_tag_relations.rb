class QuestionTagRelations < ActiveRecord::Migration
  def self.up
    create_table :question_tag_relations do |t|
      t.integer :tag_id, :null => false
      t.integer :question_id, :null => false
    end
    add_index :question_tag_relations,:tag_id
    add_index :question_tag_relations,:question_id
  end

  def self.down
  end
end
