# app/controllers/home_controller.rb
class HomeController < ApplicationController
    before_action :require_login, except: [:index]
    
    def index
      if logged_in?
        if current_user.student?
          @enrollments = current_user.enrollments.active.includes(:course )
          @upcoming_assignments = Assignment.joins(course: :enrollments)
                                           .where(enrollments: { user_id: current_user.id, status: 'active' })
                                           .upcoming
                                           .order(due_date: :asc)
                                           .limit(5)
          
          # Recent submissions by the student
          @recent_submissions = current_user.submissions
                                           .includes(assignment: :course)
                                           .order(submit_time: :desc)
                                           .limit(5)
                                           
        elsif current_user.instructor?
          @courses = current_user.taught_courses
          @recent_submissions = Submission.joins(assignment: :course)
                                        .where(courses: { instructor_id: current_user.id })
                                        .where(grade: nil)
                                        .order(submit_time: :desc)
                                        .limit(10)
        else # admin
          @total_users = User.count
          @total_courses = Course.count
          @total_assignments = Assignment.count
          @total_submissions = Submission.count
        end
      end
    end
    
    def dashboard
      # Additional dashboard data based on user role
    end
  end