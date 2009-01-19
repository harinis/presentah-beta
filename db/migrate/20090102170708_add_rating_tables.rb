class AddRatingTables < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.integer :user_id, :presentation_id, :null => false
      t.integer :rating_for_body_language, :rating_for_voice, :rating_for_message, :rating_for_slides, :default => 0
      t.string :criteria
      t.timestamps
    end
    add_column :presentations, :average_rating_for_body_language, :integer
    add_column :presentations, :average_rating_for_voice, :integer
    add_column :presentations, :average_rating_for_message, :integer
    add_column :presentations, :average_rating_for_slides, :integer
  end

  def self.down
    remove_column :presentations, :average_rating_for_body_language
    remove_column :presentations, :average_rating_for_voice
    remove_column :presentations, :average_rating_for_message
    remove_column :presentations, :average_rating_for_slides

    drop_table :ratings
  end

end
