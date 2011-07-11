class AddNumToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :num, :integer, :default => 0
  end

  def self.down
    remove_column :tags, :num
  end
end
