module Viddler
  # This class wraps Viddler's video's information.
  class Video
  
    attr_accessor :id, 
                  :url, 
                  :title, 
                  :description, 
                  :tags, 
                  :thumbnail_url,
                  :author, 
                  :length_seconds, 
                  :view_count, 
                  :update_time,
                  :comment_count, 
                  :update_time, 
                  :permissions, 
                  :comments
  
    def initialize(attributes={}) #:nodoc:
      a = attributes
      @id               = a['id']
      @title            = a['title']
      @description      = a['description']
      @tags             = a['tags']
      @url              = a['url']
      @thumbnail_url    = a['thumbnail_url']
      @author           = a['author']
      @length_seconds   = a['length_seconds'].to_i
      @view_count       = a['view_count'].to_i
      @comment_count    = a['comment_count'].to_i
      @update_time      = a['update_time'] ? Time.at(a['update_time'].to_i) : nil
      @permissions      = a['permissions'] ? a['permissions'] : nil
      @comments         = a['comment_list']['comment'].collect do |comment|
                            Viddler::Comment.new(comment)
                          end if !a['comment_list'].nil? && a['comment_list']['total'].to_i > 0
    end
    
    # Returns HTML code for video embedding.
    def embed_code(options={})
      options = {
                  :player_type => 'player',
                  :width => 437,
                  :height => 370,
                  :autoplay => 'f'
                }.merge(options)

      # get non flashvars from options
      player_type = options.delete(:player_type)
      width       = options.delete(:width)
      height      = options.delete(:height)

      flashvars = options.collect{|key,value| "#{key}=#{value}"}.join('&')

      html = <<CODE
<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="#{width}" height="#{height}" id="viddlerplayer-#{self.id}">
<param name="movie" value="http://www.viddler.com/#{player_type}/#{self.id}/" />
<param name="allowScriptAccess" value="always" />
<param name="allowFullScreen" value="true" />
<param name="flashvars" value="#{flashvars}" />
<embed src="http://www.viddler.com/#{player_type}/#{self.id}/" width="#{width}" height="#{height}" type="application/x-shockwave-flash" allowScriptAccess="always" flashvars="#{flashvars}" allowFullScreen="true" name="viddlerplayer-#{self.id}" >
</embed>
</object>'
CODE
    end
  
  end
end