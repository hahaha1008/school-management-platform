# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
    def new
    end
    
    def create
      user = User.authenticate(params[:user_name], params[:password])
      
      if user
        session[:user_id] = user.id
        redirect_to root_path, notice: "Logged in successfully!"
      else
        flash.now[:alert] = "Invalid username or password."
        render :new
      end
    end
    
    def destroy
      session[:user_id] = nil
      redirect_to login_path, notice: "Logged out successfully!"
    end
  end