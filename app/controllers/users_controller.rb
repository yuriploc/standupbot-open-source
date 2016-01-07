class UsersController < ApplicationController

  # GET /users
  def index
    @users = User.non_bot
  end

end
