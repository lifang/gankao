class AddIsUserAffiremedToExamUsers < ActiveRecord::Migration
  def self.up
    add_column :exam_users, :is_user_affiremed, :boolean, :default => 0
  end

  def self.down
    remove_column :exam_users, :is_user_affiremed
  end
end
