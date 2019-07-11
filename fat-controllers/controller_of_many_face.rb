# before, the controller taking on too much responsibility

class UsersController < ApplicationController

  def login
    if request.post?
      if session[:user_id] = User.authenticate(params[:user][:login],
                                               params[:user][:password])
        flash[:message] = "Login successful"
        redirect_to root_url
      else
        flash[:warning] = "Login unsuccessful"
      end
    end
  end

  def logout
    session[:user_id] = nil
    flash[:message] = 'Logged out'
    redirect_to :action => 'login'
  end
  # ... RESTful actions ...
end

# after
#
# Viewing each controller as a class is really just an application of the Single
# Responsibility Principle. Each controller should contain only
# the logic that pertains to the resource it represents

class SessionsController < ApplicationController

  def new
# Just render the sessions/new.html.erb template
  end

  def create
    if session[:user_id] = User.authenticate(params[:user][:login],
                                             params[:user][:password])
      flash[:message] = "Login successful"
      redirect_to root_url
    else
      flash.now[:warning] = "Login unsuccessful"
      render :action => "new"
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:message] = 'Logged out'
    redirect_to login_url
  end
end