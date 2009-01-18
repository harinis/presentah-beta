class AddThumbnailToPresentation < ActiveRecord::Migration
  def self.up
    add_column :presentations, :thumbnail, :string
  end

  def self.down
    remove_column :presentations, :thumbnail
  end
end
