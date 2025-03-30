# app/controllers/assignments_controller.rb
class AssignmentsController < ApplicationController
    before_action :require_login
    before_action :set_course
    before_action :set_assignment, only: [:show, :edit, :update, :destroy]
    before_action :authorize_instructor, only: [:new, :create, :edit, :update, :destroy]
    
    def index
      @assignments = @course.assignments
    end
    
    def show
      @submission = current_user.student? ? current_user.submissions.find_by(assignment: @assignment) : nil
      @submissions = current_user.instructor? || current_user.admin? ? @assignment.submissions.includes(:user) : []
    end
    
    def new
      @course = Course.find(params[:course_id])
      @assignment = @course.assignments.build
    end
    
    def create
      @assignment = @course.assignments.build(assignment_params)
      
      if @assignment.save
        redirect_to course_assignment_path(@course, @assignment), notice: "Assignment successfully created!"
      else
        render :new
      end
    end
    
    def edit
    end
    
    def update
      if @assignment.update(assignment_params)
        redirect_to course_assignment_path(@course, @assignment), notice: "Assignment successfully updated!"
      else
        render :edit
      end
    end
    
    def destroy
      @assignment.destroy
      redirect_to course_assignments_path(@course), notice: "Assignment successfully deleted!"
    end
    
    private
    
    def set_course
      @course = Course.find(params[:course_id])
    end
    
    def set_assignment
      @assignment = @course.assignments.find(params[:id])
    end
    
    def assignment_params
      params.require(:assignment).permit(:ass_title, :ass_description, :due_date)
    end
    
    def authorize_instructor
      unless current_user.admin? || (@course.instructor_id == current_user.id)
        redirect_to course_path(@course), alert: "Only the course instructor can perform this action."
      end
    end
  end