class Presentation < ActiveRecord::Base
  belongs_to :user
  has_many :ratings
  CRITERIA = [:body_language, :voice, :message, :slides]

  def rate(value, criteria, user)
    rating = Rating.find_or_initialize_by_user_id_and_presentation_id(user.id, self.id)
    populate_overall(rating, value) and return if criteria.nil?
    rating.send("rating_for_#{criteria.to_s}=", value.to_i)
    rating.save!
    self.send("average_rating_for_#{criteria}=", Rating.average("rating_for_#{criteria}", :conditions => ['presentation_id = ?', self.id]))
    save!
  end

  private

  def populate_overall(rating, value)
    rating.overall_rating = value
    rating.save!
    self.average_overall_rating = Rating.average("overall_rating", :conditions => ['presentation_id = ?', self.id])
  end

end
