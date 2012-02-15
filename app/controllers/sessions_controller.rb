class SessionsController < ApplicationController
 include Authentication
  def new
  end
  
  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      redirect_to root_url, :notice => "Logged in!"
    else
      flash.now.alert = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    if  current_user
     unauthenticate
    end
    
    redirect_to root_url, :notice => "Logged out!"
  end
end