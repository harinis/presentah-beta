#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/environment'
viddler = Viddler::Base.new(VIDDLER_API_KEY, VIDDLER_ADMIN_USERNAME, VIDDLER_ADMIN_PASSWORD)
user_id = ARGV.first
presentation = Presentation.find_by_id(ARGV[1])
filename = presentation.viddler_filename

begin
  p "Uploading....#{viddler}"
  p "User #{user_id}, file : #{filename}"

  description = "#{presentation.description} #{presentation.purpose}";
  description = presentation.title if description.strip.empty?
  video = viddler.upload_video(
    :title => presentation.title,
      :description => description,
      :tags =>  "user_#{user_id} #{presentation.tags}",
      :file => File.new(filename),
      :make_public => "0")
  RAILS_DEFAULT_LOGGER.info( "Video Uploaded Successfully: #{video.title}")

#  viddler.update_video(
#    video.id,
#      :title => presentation.title,
#      :description => presentation.description,
#      :tags =>  presentation.tags,
#      :view_perm => "private",
#      :view_users => "",
#      :view_use_secret => "0",
#      :embed_perm => "private",
#      :embed_users => "",
#      :commenting_perm => "private",
#      :tagging_perm => "private",
#      :download_perm => "private",
#      :download_users => "")
#  RAILS_DEFAULT_LOGGER.info( "Video Description Updated Successfully: #{video.title} for #{video.tags}")
  presentation.update_attributes(:viddler_id => video.id, :viddler_url => video.url, :status => 'completed', :thumbnail => video.thumbnail_url, :length => video.length_seconds)

rescue StandardError, Timeout::Error => e
  RAILS_DEFAULT_LOGGER.info( "Video Uploading failed for : #{video} due to exception #{e.to_s}")
  presentation.update_attributes(:status => 'failed')
end