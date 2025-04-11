# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  
  # Include Devise helpers
  include DeviseHelper
  
  helper_method :current_user, :logged_in?
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  
  def logged_in?
    !current_user.nil?
  end
  
  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this section"
      redirect_to login_path
    end
  end
  
  def require_student
    unless current_user && current_user.student?
      flash[:alert] = "You must be a student to access this section"
      redirect_to root_path
    end
  end
  
  def require_instructor
    unless current_user && current_user.instructor?
      flash[:alert] = "You must be an instructor to access this section"
      redirect_to root_path
    end
  end
  
  def require_admin
    unless current_user && current_user.admin?
      flash[:alert] = "You must be an admin to access this section"
      redirect_to root_path
    end
  end
  
  # For API authentication
  def authenticate_user!
    if request.headers['Authorization'].present?
      # JWT token authentication for API
      begin
        jwt_payload = JWT.decode(token, Rails.application.secrets.secret_key_base).first
        @current_user_id = jwt_payload['id']
      rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
        head :unauthorized
      end
    else
      # Session-based authentication for web views
      redirect_to login_path unless logged_in?
    end
  end
  
  def token
    request.headers['Authorization'].split(' ').last
  end
end