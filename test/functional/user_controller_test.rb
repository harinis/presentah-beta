require '../test_helper'

class UserControllerTest < ActionController::TestCase
  def setup
    Viddler::Base.stubs(:new).with(VIDDLER_API_KEY, VIDDLER_ADMIN_USERNAME, VIDDLER_ADMIN_PASSWORD)
  end

  def test_user_index
    tom = create_a_user
    school_presentation = Presentation.create(:title => "School", :user_id => tom.id)
    college_presentation = Presentation.create(:title => "College", :user_id => tom.id)
    business_presentation = Presentation.create(:title => "business", :user_id => tom.id)
    another_business_presentation = Presentation.create(:title => "Another business", :user_id => tom.id)
    another_college_presentation = Presentation.create(:title => "Another college", :user_id => tom.id)

    school_presentation.rate(5, 'body_language', tom)
    college_presentation.rate(2, 'body_language', tom)
    business_presentation.rate(4, 'body_language', tom)
    another_business_presentation.rate(3, 'body_language', tom)
    another_college_presentation.rate(1, 'body_language', tom)

    get :index
    assert_equal([school_presentation, business_presentation, another_business_presentation, college_presentation], assigns['top_presentations'])
    assert_equal "Home", assigns['page_name']
  end

  def test_user_creation_page
    get :create_account
    assert_not_nil assigns['user']
  end

  def test_user_creation_successful_and_session_populated_if_empty_before
    @request.session[:user] = nil
    post :create_account, :user => {:username => "tom@gmail.com", :password => "tom", :password_confirmation => "tom"}
    user = User.find_by_username("tom@gmail.com")
    assert_not_nil user
    assert_redirected_to(:action => 'review_presentations')
    assert_equal(user, @request.session[:user])
  end

  def test_user_creation_successful_and_session_not_populated_if_not_empty_before
    @request.session[:user] = User.create(:username => "mary@gmail.com", :password => "mary", :password_confirmation => "mary")
    post :create_account, :user => {:username => "tom@gmail.com", :password => "tom", :password_confirmation => "tom"}
    user = User.find_by_username("tom@gmail.com")
    assert_not_nil user
    assert_redirected_to(:action => 'review_presentations')
    assert_not_equal(user, @request.session[:user])
  end

  def test_user_creation_errors
    post :create_account, :user => {:username => "tom@gmail.com", :password => "tom", :password_confirmation => ""}
    assert_nil User.find_by_username("tom@gmail.com")
    assert_template('create_account')
  end

  def test_login_successful_without_presentation_params
    @request.session[:presentation_params] = nil
    user = create_a_user
    post :login, :user => {:username => "tom@gmail.com", :password => "tom"}
    assert_redirected_to(:action => 'post_presentation')
    assert_equal(user, @request.session[:user])
  end

  def test_login_successful_with_presentation_params_and_presentation_created
    @request.session[:presentation_params] = {:viddler_filename => "filename", :title => "school", :description => "rain water harvesting", :purpose => "general", :tags => "tag1 tag2"}
    user = create_a_user
    UserController.any_instance.expects(:upload_video_to_viddler)

    post :login, :user => {:username => "tom@gmail.com", :password => "tom"}

    assert_redirected_to(:action => 'review_presentations')
    assert_equal(user, @request.session[:user])
    presentation = Presentation.first
    assert_equal "filename", presentation.viddler_filename
    assert_equal "school", presentation.title
    assert_equal user, presentation.user
  end

  def test_post_presentation_page
    user = mock
    @request.session[:user] = user
    get :post_presentation
    assert_equal(user, assigns['user'])
  end

  def test_post_presentation_valid_params_and_user_signed_in
    user = create_a_user
    @request.session[:user] = user
    UserController.any_instance.expects(:upload_video_to_viddler)

    post :post_presentation, {:presentation_video => stub(:path => "filename"), :title => "school", :description => "rain water harvesting", :purpose => "general", :tags => "tag1 tag2"}

    assert_equal(user, assigns['user'])
    assert_nil(@request.session[:presentation_params])
    assert_redirected_to(:action => 'review_presentations')
    presentation = Presentation.first
    assert_equal "filename", presentation.viddler_filename
    assert_equal "school", presentation.title
    assert_equal user, presentation.user
  end

  def test_post_presentation_invalid_params_and_user_signed_in_title_empty
    user = create_a_user
    @request.session[:user] = user

    post :post_presentation, {:presentation_video => stub(:path => "filename"), :title => "", :description => "rain water harvesting", :purpose => "general", :tags => "tag1 tag2"}

    assert_equal(user, assigns['user'])
    assert_nil(@request.session[:presentation_params])
    assert_template('post_presentation')
    assert_equal 0, Presentation.count
    assert_equal "Presentation and Title are mandatory", flash[:notice]
  end

  def test_post_presentation_invalid_params_and_user_signed_in_presentation_empty
    user = create_a_user
    @request.session[:user] = user

    post :post_presentation, {:presentation_video => "", :title => "school", :description => "rain water harvesting", :purpose => "general", :tags => "tag1 tag2"}

    assert_equal(user, assigns['user'])
    assert_nil(@request.session[:presentation_params])
    assert_template('post_presentation')
    assert_equal 0, Presentation.count
    assert_equal "Presentation and Title are mandatory", flash[:notice]
    assert_nil(flash[:show_loading_image])
  end

  def test_post_presentation_valid_params_and_user_not_signed_in
    @request.session[:user] = nil

    post :post_presentation, {:presentation_video => stub(:path => "filename"), :title => "school", :description => "rain water harvesting", :purpose => "general", :tags => "tag1 tag2"}

    assert_nil(assigns['user'])
    assert_equal({:viddler_filename => "filename", :title => "school", :description => "rain water harvesting", :purpose => "general", :tags => "tag1 tag2"}, @request.session[:presentation_params])
    assert_redirected_to(:action => 'sign_in')
    assert_equal 0, Presentation.count
  end

  def test_review_presentations_with_user_signed_in
    user = create_a_user
    another_user = User.create(:username => "mary@gmail.wcom", :password => "tom", :password_confirmation => "tom")
    @request.session[:user] = user

    school_presentation = Presentation.create(:title => "School", :user_id => user.id)
    college_presentation = Presentation.create(:title => "College", :user_id => another_user.id, :status => 'completed')
    another_college_presentation = Presentation.create(:title => "College 1", :user_id => another_user.id, :status => 'pending')
    business_presentation = Presentation.create(:title => "business", :user_id => another_user.id, :status => 'completed')

    get :review_presentations
    assert_equal([college_presentation, business_presentation], assigns['other_presentations'])
  end

  def test_review_presentations_with_user_not_signed_in
    user = create_a_user
    another_user = User.create(:username => "mary@gmail.wcom", :password => "tom", :password_confirmation => "tom")
    @request.session[:user] = nil

    school_presentation = Presentation.create(:title => "School", :user_id => user.id, :status => 'completed')
    college_presentation = Presentation.create(:title => "College", :user_id => another_user.id, :status => 'completed')
    business_presentation = Presentation.create(:title => "business", :user_id => another_user.id, :status => 'completed')

    get :review_presentations
    assert_equal([school_presentation, college_presentation, business_presentation], assigns['other_presentations'])
  end

  def test_presentation_view_without_viddler_response_error_with_user_signed_in
    user = create_a_user
    presentation = Presentation.create(:title => "School", :user_id => user.id, :status => 'completed', :viddler_id => "1")
    viddler = mock
    viddler_video = mock(:embed_code => nil)
    Viddler::Base.expects(:new).with(VIDDLER_API_KEY, VIDDLER_ADMIN_USERNAME, VIDDLER_ADMIN_PASSWORD).returns(viddler)
    viddler.expects(:find_video_by_id).with(presentation.viddler_id).returns(viddler_video)

    get :presentation, :id => presentation.id
  end

  [:body_language, :voice, :message, :slides].each do |criteria|
    define_method "test_rating_presentation_for_#{criteria}".to_sym do
      user = create_a_user
      @request.session[:user] = user
      presentation = Presentation.create(:title => "School", :user_id => user.id, :status => 'completed')

      post :rate_presentation, :presentation => presentation.id, "rating_value_#{criteria.to_s}".to_sym => 4
      presentation.reload
      assert_equal 4, presentation.ratings.first.send("rating_for_#{criteria}")
      assert_equal 4, presentation.send("average_rating_for_#{criteria}")
      assert_equal 4, assigns['user_rating'][criteria]
      assert_equal 4, assigns['presentation'].send("average_rating_for_#{criteria}")
      assert_equal 1, assigns['user_rating'][:overall]
    end
  end

  def test_user_updating_his_presentation
    user = create_a_user
    @request.session[:user] = user
    presentation = Presentation.create(:title => "School", :user_id => user.id, :status => 'completed')
    presentation.rate(4, 'body_language', user)

    post :rate_presentation, :presentation => presentation.id, :rating_value_body_language => 2
    presentation.reload
    assert_equal 2, presentation.ratings.first.rating_for_body_language
    assert_equal 2, presentation.average_rating_for_body_language
  end

  def test_average_rating_per_presentation
    user = create_a_user
    another_user = User.create(:username => "mary@gmail.wcom", :password => "tom", :password_confirmation => "tom")

    @request.session[:user] = user
    presentation = Presentation.create(:title => "School", :user_id => user.id, :status => 'completed')
    presentation.rate(4, 'body_language', another_user)

    post :rate_presentation, :presentation => presentation.id, :rating_value_body_language => 2
    presentation.reload
    assert_equal 2, Rating.find_by_user_id_and_presentation_id(user.id, presentation.id).rating_for_body_language
    assert_equal 3, presentation.average_rating_for_body_language
    assert_equal assigns['user_rating'][:body_language], 2
    assert_equal assigns['presentation'].average_rating_for_body_language, 3
  end


  private

  def create_a_user
    User.create(:username => "tom@gmail.com", :password => "tom", :password_confirmation => "tom")
  end

end