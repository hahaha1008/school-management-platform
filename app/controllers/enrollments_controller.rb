# app/controllers/enrollments_controller.rb
class EnrollmentsController < ApplicationController
    before_action :require_login
    before_action :set_course
    before_action :set_enrollment, only: [:update, :destroy]
    before_action :require_student, only: [:create]
    def index
        redirect_to course_path(@course)
      end
      def create
        @enrollment = @course.enrollments.build(user: current_user, status: 'active')
        
        if @enrollment.save
          redirect_to course_path(@course), notice: "✅ You have successfully enrolled in \"#{@course.course_name}\"! You can now access all course materials and assignments."
        else
          redirect_to courses_path, alert: @enrollment.errors.full_messages.join(", ")
        end
      end
    
    def update
      if @enrollment.update(enrollment_params)
        redirect_to course_path(@course), notice: "Your enrollment status has been updated!"
      else
        redirect_to course_path(@course), alert: @enrollment.errors.full_messages.join(", ")
      end
    end
    
    def destroy
      course_name = @course.course_name
      if @enrollment.destroy
        redirect_to courses_path, notice: "You have successfully dropped #{course_name}."
      else
        redirect_to course_path(@course), alert: "There was an error dropping this course."
      end
    end
    
    private
    
    def set_course
      @course = Course.find(params[:course_id])
    end
    
    def set_enrollment
      @enrollment = if current_user.admin?
                      @course.enrollments.find(params[:id])
                    else
                      @course.enrollments.find_by!(user_id: current_user.id)
                    end
    end
    
    def enrollment_params
      params.require(:enrollment).permit(:status)
    end
    
    def require_student
      unless current_user.student?
        redirect_to courses_path, alert: "Only students can enroll in courses."
      end
    end
  end