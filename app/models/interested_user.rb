class InterestedUser < ActiveRecord::Base
  validates_presence_of :email, :message => "Please enter an email address"
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
          :on => :create, :message => "Please enter a valid email address"
end
