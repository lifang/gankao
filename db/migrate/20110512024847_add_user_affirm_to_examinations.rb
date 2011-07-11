class AddUserAffirmToExaminations < ActiveRecord::Migration
  def self.up
    add_column :examinations, :user_affirm, :boolean, :default => 0
  end

  def self.down
    remove_column :examinations, :user_affirm
  end
end
