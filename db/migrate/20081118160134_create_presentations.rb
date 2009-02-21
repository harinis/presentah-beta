class CreatePresentations < ActiveRecord::Migration
  def self.up
    create_table :presentations do |t|
      t.integer :user_id, :null => false
      t.integer :viddler_id
      t.string :viddler_filename, :title, :status
      t.text :description, :tags
      t.timestamps
    end
  end

  def self.down
    drop_table :presentations
  end
end
