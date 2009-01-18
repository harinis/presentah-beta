class Presentation < ActiveRecord::Base
  belongs_to :user
  has_many :ratings

  def rate(value, criteria, user)
    rating = Rating.find_or_initialize_by_user_id_and_presentation_id(user.id, self.id)
    rating.send("rating_for_#{criteria.to_s}=", value.to_i)
    rating.save!
    self.send("average_rating_for_#{criteria}=" , Rating.average("rating_for_#{criteria}", :conditions => ['presentation_id = ?', self.id]))
    save!
  end
  
end