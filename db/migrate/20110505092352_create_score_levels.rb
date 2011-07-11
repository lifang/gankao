class CreateScoreLevels < ActiveRecord::Migration
  def self.up
    create_table :score_levels do |t|
      t.integer :examination_id, :null => false
      t.string :key
      t.string :value


    end
    add_index :score_levels,:examination_id
    add_index :score_levels,:key
  end

  def self.down
    drop_table :score_levels
  end
end
