# before it was monolithic controller, non-restful
class AdminController
  def users
    per_page = Variable::default_pagination_value
    @users = User.find(:all)
# First, check to see if there
# was an operation performed
    if not params[:operation].nil? then
      if (params[:operation] == "reset_password") then
        user = User.find(params[:id])
        user.generate_password_reset_access_key
        user.password_confirmation = user.password
        user.email_confirmation = user.email
        user.save!
        flash[:notice] = user.first_name + " " +
            user.last_name + "'s password has been reset."
      end
      if (params[:operation] == "delete_user") then
        user = User.find(params[:id])
        user.item_status = ItemStatus.find_deleted()
        user.password_confirmation = user.password
        user.email_confirmation = user.email
        user.save!
        flash[:notice] = user.first_name + " " +
            user.last_name + " has been deleted"
      end
      if (params[:operation] == "activate_user") then
        user = User.find(params[:id])
        user.item_status = ItemStatus.find_active()
        user.password_confirmation = user.password
        user.email_confirmation = user.email
        user.save!
        flash[:notice] = user.first_name + " " +
            user.last_name + " has been activated"
      end
      if (params[:operation] == "show_user") then
        @user = User.find(params[:id])
        render :template => show_user
        return true
      end
    end
    user_order = 'username'
    if not params[:user_sort_field].nil? then
      user_order = params[:user_sort_field]
      if !session[:user_sort_field].nil? &&
          user_order == session[:user_sort_field] then
        user_order += " DESC"
      end
      session[:user_sort_field] = user_order
    end
    @user_pages, @users = paginate(:users,
                                   :order => user_order,
                                   :conditions => ['item_status_id <> ?',
                                                   ItemStatus.find_deleted().id],
                                   :per_page => per_page)
  end
end

/admin/users?operation=reset_password?id=x
/admin/users?operation=delete_user?id=x
/admin/users?operation=activate_user?id=x
/admin/users?operation=show_user?id=x
/admin/users


# after using REST architecture
POST   /admin/users/:id/password
DELETE /admin/users/:id
POST   /admin/users/:id/activation
GET    /admin/users/:id
GET    /admin/users

class UsersController < ApplicationController
  def index
    per_page = Variable::default_pagination_value
    user_order = 'username'
    if not params[:user_sort_field].nil? then
      user_order = params[:user_sort_field]
      if !session[:user_sort_field].nil? &&
          user_order == session[:user_sort_field] then
        user_order += " DESC"
      end
      session[:user_sort_field] = user_order
    end
    @user_pages, @users = paginate(:users,
                                   :order => user_order,
                                   :conditions => ['item_status_id <> ?',
                                                   ItemStatus.find_deleted().id],
                                   :per_page => per_page)
  end
  def destroy
    user = User.find(params[:id])
    user.item_status = ItemStatus.find_deleted()
    user.password_confirmation = user.password
    user.email_confirmation = user.email
    user.save!
    flash[:notice] = user.first_name + " " +
        user.last_name + " has been deleted"
  end
  def show
    @user = User.find(params[:id])
    render :template => show_user
  end
end

class PasswordsController < ApplicationController
  def create
    user = User.find(params[:id])
    user.generate_password_reset_access_key
    user.password_confirmation = user.password
    user.email_confirmation = user.email
    user.save!
    flash[:notice] = user.first_name + " " +
        user.last_name + "'s password has been reset."
  end
end

class ActivationsController < ApplicationController
  def create
    user = User.find(params[:id])
    user.item_status = ItemStatus.find_active()
    user.password_confirmation = user.password
    user.email_confirmation = user.email
    user.save!
    flash[:notice] = user.first_name + " " +
        user.last_name + " has been activated"
  end
end


namespace :admin do
  resources :users do
    resource :passwords
    resource :activations
  end
end


