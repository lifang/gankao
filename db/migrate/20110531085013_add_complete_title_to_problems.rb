class AddCompleteTitleToProblems < ActiveRecord::Migration
  def self.up
    add_column :problems, :complete_title, :text
  end

  def self.down
    remove_column :problems, :complete_title
  end
end
