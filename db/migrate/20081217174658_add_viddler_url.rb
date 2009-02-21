class AddViddlerUrl < ActiveRecord::Migration
  def self.up
    add_column :presentations, :viddler_url, :string
    add_column :presentations, :length, :integer
  end

  def self.down
    remove_column :presentations, :viddler_url
    remove_column :presentations, :length    
  end
end
