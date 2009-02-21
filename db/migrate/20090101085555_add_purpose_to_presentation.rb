class AddPurposeToPresentation < ActiveRecord::Migration
  def self.up
    add_column :presentations, :purpose, :text
  end

  def self.down
    remove_column :presentations, :purpose    
  end
end
