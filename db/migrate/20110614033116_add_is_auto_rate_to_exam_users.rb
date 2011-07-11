class AddIsAutoRateToExamUsers < ActiveRecord::Migration
  def self.up
    add_column :exam_users, :is_auto_rate, :boolean, :default => 0
  end

  def self.down
    remove_column :exam_users, :is_auto_rate
  end
end
