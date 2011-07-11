class CreateRaterUserRelations < ActiveRecord::Migration
  def self.up
    create_table :rater_user_relations do |t|
      t.integer :exam_user_id, :null => false
      t.integer :exam_rater_id, :null => false
      t.boolean :is_marked, :default => 0
      
    end
    add_index :rater_user_relations,:exam_user_id
    add_index :rater_user_relations,:exam_rater_id
    add_index :rater_user_relations,:is_marked
  end

  def self.down
    drop_table :rater_user_relations
  end
end
