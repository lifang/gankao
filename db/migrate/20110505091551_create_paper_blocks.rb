class CreatePaperBlocks < ActiveRecord::Migration
  def self.up
    create_table :paper_blocks do |t|
      t.integer :paper_id, :null => false
      t.string :title
      t.string :description

      t.timestamps
    end
    add_index :paper_blocks,:paper_id
  end

  def self.down
    drop_table :paper_blocks
  end
end
