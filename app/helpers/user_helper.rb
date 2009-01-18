module UserHelper
  def user_has_presentations?
    @user && !@user.presentations.empty?
  end
end
