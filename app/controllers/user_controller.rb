class UserController < ApplicationController
  before_filter :get_viddler_instance, :only => [:presentation]
  def index
    @page_name = 'Home'
  end

  def create_account
    @user = User.new(params[:user])
    return if request.get?
    if @user.save
      session[:user] = @user if session[:user].blank?
      redirect_to :action => 'review_presentations' and return
    end
  end

  def login
    @user = User.find_by_username_and_password(params[:user][:username], params[:user][:password])
    flash[:notice] = 'Invalid user email or password' and redirect_to '/' and return unless @user
    session[:user] = @user
    if session[:presentation_params]
      save_and_upload(session[:presentation_params])
      redirect_to :action => 'review_presentations' and return
    end
    redirect_to post_presentation_path
  end

  def sign_in
  end

  def post_presentation
    @user = session[:user]
    return if request.get?
    flash[:notice] = "Presentation and Title are mandatory" and return if params[:presentation_video].blank? || params[:title].blank?
    unless @user
      session[:presentation_params] = {:viddler_filename =>params[:presentation_video].path, :title => params[:title], :description => params[:description], :purpose => params[:purpose], :tags => params[:tags]}
      redirect_to :action => 'sign_in'
      return
    end
    save_and_upload(params)
    session[:presentation_params] = nil
    redirect_to :action => 'review_presentations'
  end

  def review_presentations
    @user = session[:user] if session[:user]
    @other_presentations = Presentation.find(:all, :conditions => ["user_id <> ? and status = 'completed'", (@user.nil? ? -1 : @user.id)])
  end

  def presentation
    @presentation = Presentation.find_by_id(params[:id])
    begin
      @viddler_video = @viddler.find_video_by_id(@presentation.viddler_id)
    rescue Viddler::ResponseError
      @viddler_video = @viddler.find_video_by_url(@presentation.viddler_url)
    end
    load_ratings if session[:user]
  end

  def rate_presentation
    @presentation = Presentation.find_by_id(params[:presentation])
    Presentation::CRITERIA.each do|criteria|
      rating_value = params["rating_value_#{criteria}"]
      @presentation.rate(rating_value, criteria, session[:user]) unless rating_value.blank?
    end
    load_ratings
    render :partial => 'rating'
  end

  def forgot_password
    user = User.find_by_username(params[:email])
    Mailer.deliver_forgot_password(user.username, user.password)
    flash[:notice] = "An email has been sent to #{user.username} with your password!"
    redirect_to :action => 'sign_in'
  end

  def search
    @results = Presentation.find(:all, :conditions => ['average_overall_rating > 0'], :order => 'average_overall_rating DESC')
  end

  def sign_out
    session[:user] = nil
    redirect_to '/'
  end

  private

  def get_viddler_instance
    @viddler = Viddler::Base.new(VIDDLER_API_KEY, VIDDLER_ADMIN_USERNAME, VIDDLER_ADMIN_PASSWORD)
  end

  def save_and_upload(params)
    current_presentation = Presentation.create(:viddler_filename =>params[:viddler_filename] || params[:presentation_video].path, :user => @user, :status => 'pending')
    current_presentation.update_attributes(:title => params[:title], :description => params[:description], :tags => params[:tags], :purpose => params[:purpose])
    upload_video_to_viddler(@user, current_presentation)
  end

  def upload_video_to_viddler(user, presentation)
    system "ruby #{File.expand_path(RAILS_ROOT)}/script/upload_video.rb #{user.id} #{presentation.id} &"
  end

  def load_ratings
    @user_rating = {}
    Presentation::CRITERIA.each do|criteria|
      @user_rating[criteria] = session[:user].rating_for(@presentation, criteria)
    end
  end

end
