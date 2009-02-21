class AddRatingTables < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.integer :user_id, :presentation_id, :null => false
      t.integer :body_language_rating, :voice_rating, :message_rating, :slides_rating, :overall_rating, :default => 0
      t.timestamps
    end
    add_column :presentations, :average_body_language_rating, :integer
    add_column :presentations, :average_voice_rating, :integer
    add_column :presentations, :average_message_rating, :integer
    add_column :presentations, :average_slides_rating, :integer
    add_column :presentations, :average_overall_rating, :integer
  end

  def self.down
    remove_column :presentations, :average_body_language_rating
    remove_column :presentations, :average_voice_rating
    remove_column :presentations, :average_message_rating
    remove_column :presentations, :average_slides_rating
    remove_column :presentations, :average_overall_rating

    drop_table :ratings
  end

end
