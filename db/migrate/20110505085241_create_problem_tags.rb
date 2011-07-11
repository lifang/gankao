class CreateProblemTags < ActiveRecord::Migration
  def self.up
    create_table :problem_tags do |t|
      t.integer :problem_id, :null => false
      t.integer :total_num, :default => 1
    end
    add_index :problem_tags,:problem_id
  end

  def self.down
    drop_table :problem_tags
  end
end
