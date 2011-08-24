class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.integer :user_id, :null => false
      t.string :note_url
      t.timestamps
    end
    add_index :notes,:user_id
  end

  def self.down
    drop_table :notes
  end
end
