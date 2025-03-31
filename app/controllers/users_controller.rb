# app/controllers/users_controller.rb
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]
  before_action :require_login, except: [:new, :create]
  before_action :require_same_user, only: [:edit, :update, :show]

  def new
    @user = User.new
    @user.build_profile  # Initialize a new profile for the form
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      # Create profile if not using nested attributes
      @user.create_profile(profile_params) unless params[:user][:profile_attributes]
      
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Account successfully created!"
    else
      render :new
    end
  end

  def show
    # The show action is fine
  end
  
  def edit
    # Create a profile if one doesn't exist
    @user.build_profile if @user.profile.nil?
  end
  
  def update
    # This method needs fixing
    if @user.update(user_params)
      # Success case
      redirect_to @user, notice: "Profile successfully updated!"
    else
      # Failure case
      render :edit
    end
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
    # Make sure to permit nested profile attributes
    params.require(:user).permit(
      :user_name, 
      :password, 
      :role, 
      :expire_date,
      profile_attributes: [:id, :phone_num, :address, :major]
    )
  end

  def profile_params
    params.require(:user).permit(profile: [:phone_num, :address, :major])[:profile] || {}
  end
  
  def require_same_user
    unless current_user == @user || current_user.admin?
      redirect_to root_path, alert: "You can only view/edit your own profile."
    end
  end
end