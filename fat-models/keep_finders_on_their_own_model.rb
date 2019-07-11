# before
class UsersController < ApplicationController
  def index
    @user = User.find(params[:id])
    @memberships =
        @user.memberships.where(active: true).
            limit(5).
            order("last_active_on DESC")
  end
end

# now

class Membership
  belongs_to :user

  scope :only_active, -> { where(active: true)}
  scope :order_by_activity, -> {order("last_active_on DESC")}

end

class User
  has_many :memberships

  def find_recent_active_memberships
    memberships.only_active.order_by_activity.limit(5)
  end
end

class UsersController < ApplicationController
  def index
    @user = User.find(params[:id])
    @memberships = @user.find_recent_active_memberships
  end
end

(article.current_version ? article.current_version.version : 0) + 1
