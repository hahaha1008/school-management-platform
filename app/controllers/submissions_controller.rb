# app/controllers/submissions_controller.rb
class SubmissionsController < ApplicationController
    before_action :require_login
    before_action :set_course
    before_action :set_assignment
    before_action :set_submission, only: [:edit, :update, :destroy]
    before_action :require_student, only: [:new, :create, :edit, :update, :destroy]
    before_action :authorize_user, only: [:edit, :update, :destroy]
    before_action :require_instructor_for_grading, only: [:grade]
    
    def new
      @course = Course.find(params[:course_id])
      @assignment = @course.assignments.find(params[:assignment_id])
      
      if @assignment.submissions.exists?(user_id: current_user.id)
        redirect_to course_assignment_path(@course, @assignment), alert: "You have already submitted this assignment."
        return
      end
      
      @submission = @assignment.submissions.build(user: current_user)
    end
    
    def create
      @submission = @assignment.submissions.build(submission_params)
      @submission.user = current_user
      
      if @submission.save
        redirect_to course_assignment_path(@course, @assignment), notice: "Assignment successfully submitted!"
      else
        render :new
      end
    end

   
    def show
      @course = Course.find(params[:course_id])
      @assignment = @course.assignments.find(params[:assignment_id])
      @submission = @assignment.submissions.find(params[:id])
      
      # Authorize access
      unless current_user.admin? || current_user.id == @submission.user_id || 
             current_user.id == @assignment.course.instructor_id
        redirect_to course_assignment_path(@course, @assignment), 
                    alert: "You do not have permission to view this submission."
      end
    end
    
    def edit
    end
    
    def update
      if @submission.update(submission_params)
        redirect_to course_assignment_path(@course, @assignment), notice: "Submission successfully updated!"
      else
        render :edit
      end
    end
    
    def destroy
      @submission.destroy
      redirect_to course_assignment_path(@course, @assignment), notice: "Submission successfully deleted!"
    end
    
    def grade
      @submission = @assignment.submissions.find(params[:id])
      
      if @submission.update(grade: params[:grade])
        redirect_to course_assignment_path(@course, @assignment), notice: "Submission successfully graded!"
      else
        redirect_to course_assignment_path(@course, @assignment), alert: "Error grading submission."
      end
    end
    
    private
    
    def set_course
      @course = Course.find(params[:course_id])
    end
    
    def set_assignment
      @assignment = @course.assignments.find(params[:assignment_id])
    end
    
    def set_submission
      @submission = if current_user.admin? || (@course.instructor_id == current_user.id)
                      @assignment.submissions.find(params[:id])
                    else
                      @assignment.submissions.find_by!(user_id: current_user.id)
                    end
    end
    
    def submission_params
      params.require(:submission).permit(:content)
    end
    
    def authorize_user
      unless current_user.admin? || @submission.user_id == current_user.id
        redirect_to course_assignment_path(@course, @assignment), alert: "You can only manage your own submissions."
      end
    end
    
    def require_instructor_for_grading
      unless current_user.admin? || (@course.instructor_id == current_user.id)
        redirect_to course_assignment_path(@course, @assignment), alert: "Only the course instructor can grade submissions."
      end
    end
  end