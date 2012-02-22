require 'rack/oauth2'

class FacebooksController < ApplicationController
 
  include Authentication
  
  # handle Facebook Auth Cookie generated by JavaScript SDK
  def show
  
   auth = Facebook.auth.from_cookie(cookies)
    authenticate Facebook.identify(auth.user)
   
   # redirect_to dashboard_url
   redirect_to root_url
  end

  # handle Normal OAuth flow: start
  def new
    redirect_to client.authorization_uri(
      :scope => Facebook.config[:scope]
    )
  end

  # handle Normal OAuth flow: callback
  def create
    client.authorization_code = params[:code]
    access_token = client.access_token!
    user = FbGraph::User.me(access_token).fetch
    authenticate Facebook.identify(user)
   # redirect_to dashboard_url
   redirect_to root_url
  end

  def destroy
    unauthenticate
    redirect_to root_url
  end

  private

  def client
    unless @client
      @client = Facebook.auth.client
      @client.redirect_uri = callback_facebook_url
    end
    @client
  end

end
