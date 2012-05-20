class UsersController < ApplicationController
  before_filter :title

  def new
    @signin_failure = false
  end

  def create
    cookies.delete :auth_token
    params[:user].merge!(default_item_role)
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
      @user.send_mail
      self.current_user = @user
      render :action => 'success'
    else
      @signin_failure = true
      render :action => 'new'
    end
  end

  private

  def title
    @title = application_title('message_signup')
  end
end
