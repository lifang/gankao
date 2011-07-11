class AddTotalScoreToExamUsers < ActiveRecord::Migration
  def self.up
    add_column :exam_users, :total_score, :integer, :default => 0
  end

  def self.down
    remove_column :exam_users, :total_score
  end
end
