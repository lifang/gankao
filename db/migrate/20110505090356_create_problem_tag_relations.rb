class CreateProblemTagRelations < ActiveRecord::Migration
  def self.up
    create_table :problem_tag_relations do |t|
      t.integer :tag_id, :null => false
      t.integer :problem_id, :null => false


    end
    add_index :problem_tag_relations,:tag_id
    add_index :problem_tag_relations,:problem_id
  end

  def self.down
    drop_table :problem_tag_relations
  end
end
