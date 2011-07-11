class RemoveUserAffirmFromExamUsers < ActiveRecord::Migration
  def self.up
    remove_column :exam_users, :user_affirm
  end

  def self.down
    add_column :exam_users, :user_affirm, :boolean
  end
end
