class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token

  before_filter :check_user, :except => ["login", 'verify_user', 'viral_load_stats',
                                         'vl_result_by_npid', 'patient_lab_trail']

  protected

  def check_user

     if current_user.blank?
       redirect_to "/login"
     end
  end

  def current_user

    @user =  User.find(session[:user_id])
  end
end
