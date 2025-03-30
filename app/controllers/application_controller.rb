# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?
  
  private
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
  end
  
  def logged_in?
    !!current_user
  end
  
  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Please log in to access this page."
    end
  end
  
  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end
  
  def require_instructor
    unless current_user&.instructor? || current_user&.admin?
      redirect_to root_path, alert: "Access denied. Instructor privileges required."
    end
  end
  
  def require_student
    unless current_user&.student?
      redirect_to root_path, alert: "Access denied. Student privileges required."
    end
  end
end