# app/controllers/courses_controller.rb
class CoursesController < ApplicationController
    before_action :require_login
    before_action :set_course, only: [:show, :edit, :update, :destroy]
    before_action :require_instructor_or_admin, only: [:new, :create, :edit, :update, :destroy]
    
    def index
        @courses = if current_user.admin?
                    Course.all
                  elsif current_user.instructor?
                    current_user.taught_courses
                  else
                    # Show ALL courses to students (not just enrolled ones)
                    Course.all
                  end
    end
    
    def show
      @assignments = @course.assignments
      @students = @course.students
    end
    
    def new
      @course = Course.new
    end
    
    def create
      @course = Course.new(course_params)
      @course.instructor_id = current_user.id unless current_user.admin?
      
      if @course.save
        redirect_to @course, notice: "Course successfully created!"
      else
        render :new
      end
    end
    
    def edit
    end
    
    def update
      if @course.update(course_params)
        redirect_to @course, notice: "Course successfully updated!"
      else
        render :edit
      end
    end
    
    def destroy
      @course.destroy
      redirect_to courses_path, notice: "Course successfully deleted!"
    end
    
    private
    
    def set_course
      @course = Course.find(params[:id])
    end
    
    def course_params
      params.require(:course).permit(:course_name, :description, :instructor_id, :term)
    end
    
    def require_instructor_or_admin
      unless current_user.instructor? || current_user.admin?
        redirect_to courses_path, alert: "Only instructors or admins can perform this action."
      end
    end
  end