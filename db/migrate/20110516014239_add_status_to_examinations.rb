class AddStatusToExaminations < ActiveRecord::Migration
  def self.up
    add_column :examinations, :status, :integer, :default => 0
  end

  def self.down
    remove_column :examinations, :status
  end
end
