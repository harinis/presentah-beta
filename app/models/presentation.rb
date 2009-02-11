class Presentation < ActiveRecord::Base
  belongs_to :user
  has_many :ratings
  CRITERIA = [:body_language, :voice, :message, :slides, :overall]

  def rate(value, criteria, user)
    rating = Rating.find_or_initialize_by_user_id_and_presentation_id(user.id, self.id)
    rating.send("#{criteria.to_s}_rating=", value.to_i)
    rating.save!
    self.send("average_#{criteria}_rating=", Rating.average("#{criteria}_rating", :conditions => ['presentation_id = ?', self.id]))
    save!
  end

end
