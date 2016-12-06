class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_filter :check_user, :except => ["login", 'verify_user']

  protected

  def check_user

     if User.current.blank?
       redirect_to "/login"
     end
  end
end
