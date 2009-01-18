class User < ActiveRecord::Base
  has_many :presentations
  has_many :ratings
  
  has_many :failed_presentations, :class_name => "Presentation", :conditions => "presentations.status = 'failed'"
  has_many :pending_presentations, :class_name => "Presentation", :conditions => "presentations.status = 'pending'"
  has_many :uploaded_presentations, :class_name => "Presentation", :conditions => "presentations.status = 'completed'"
  validates_presence_of :username, :message => "Please enter an email address"
  validates_format_of :username, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create, :message => "Please enter a valid email address" 
  validates_uniqueness_of :username, :message => "Email address already registered! Please enter another address"
  validates_presence_of :password, :message => "Please enter a password"
  validates_confirmation_of :password, :message => "The passwords do not match"
  validates_presence_of :password_confirmation, :if => :password_changed?, :message => "Please confirm your password"

  def rating_for(presentation, criteria)
    user_rating = Rating.find_by_user_id_and_presentation_id(self.id, presentation.id)
    return 0 if user_rating.nil?
    rating = user_rating.send("rating_for_#{criteria.to_s}")
    rating.nil? ? 0 : rating
  end
end
