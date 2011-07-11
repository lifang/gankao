class AddPaperJsUrlToPapers < ActiveRecord::Migration
  def self.up
    add_column :papers, :paper_js_url, :string
  end

  def self.down
    remove_column :papers, :paper_js_url
  end
end
