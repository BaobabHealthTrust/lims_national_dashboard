class UserController < ApplicationController
  def index
    @users = User.all
  end

  def login
    render :layout => false
  end

  def logout
    session[:user_id] = nil
    User.current = nil
    redirect_to "/user/login"
  end

  def create
    @message = params[:message]
    @status = params[:success]
    render :layout => false
  end

  def edit
    @users = User.all
    render :layout => false
  end

  def edit_user
    user = User.where(:username => params[:user_name]).first
    render :text => view_context.edit_user(user)
  end

  def delete
    user = User.find(params[:user_id])
    user.update_attributes(:voided => true)
    render :text =>  "User successfully voided!" and return
  end

  def verify_user

    state = User.authenticate(params[:username],params[:password])
   if state
      user = User.find_by_username(params[:username])
      session[:user_id] = user.id
      User.current = user
    end

    render :text => state.to_json
  end

  def save
    results = User.create_user(params[:username], params[:password],params[:user_role])
    render :text => results.to_json
  end

  def save_edit
    results = User.update_user(params[:user_name_old],params[:username],params[:password],params[:user_role])
    render :text => results.to_json
  end

end
