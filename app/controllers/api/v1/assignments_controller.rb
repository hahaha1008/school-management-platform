# app/controllers/api/v1/assignments_controller.rb
module Api
    module V1
      class AssignmentsController < ApiController
        before_action :set_course
        before_action :set_assignment, only: [:show]
        before_action :authorize_access
        
        # GET /api/v1/courses/:course_id/assignments
        def index
          @assignments = @course.assignments.order(due_date: :asc)
          
          render json: {
            status: 'success',
            data: @assignments.map { |assignment| 
              assignment_to_json(assignment)
            }
          }, status: :ok
        end
        
        # GET /api/v1/courses/:course_id/assignments/:id
        def show
          # Include submission if student
          submission = nil
          if current_user.student?
            submission = @assignment.submissions.find_by(user_id: current_user.id)
          end
          
          # Include all submissions if instructor
          submissions = []
          if current_user.instructor? || current_user.admin?
            submissions = @assignment.submissions.includes(:user)
              .order(submit_time: :desc)
              .map { |s| {
                id: s.id,
                student: s.user.user_name,
                student_id: s.user_id,
                submit_time: s.submit_time,
                grade: s.grade
              }}
          end
          
          render json: {
            status: 'success',
            data: assignment_to_json(@assignment).merge({
              description: @assignment.ass_description,
              submission: submission ? {
                id: submission.id,
                submit_time: submission.submit_time,
                grade: submission.grade,
                content: submission.content
              } : nil,
              submissions: current_user.instructor? || current_user.admin? ? submissions : nil
            })
          }, status: :ok
        end
        
        private
        
        def set_course
          @course = Course.find(params[:course_id])
        end
        
        def set_assignment
          @assignment = @course.assignments.find(params[:id])
        end
        
        def authorize_access
          # Students must be enrolled in the course
          if current_user.student? && !current_user.courses.include?(@course)
            render json: {
              status: 'error',
              message: 'You are not enrolled in this course'
            }, status: :forbidden
            return
          end
          
          # Instructors must be teaching this course
          if current_user.instructor? && @course.instructor_id != current_user.id
            render json: {
              status: 'error',
              message: 'You are not teaching this course'
            }, status: :forbidden
            return
          end
        end
        
        def assignment_to_json(assignment)
          {
            id: assignment.id,
            title: assignment.ass_title,
            due_date: assignment.due_date,
            has_submitted: current_user.student? ? 
              assignment.submissions.exists?(user_id: current_user.id) : nil
          }
        end
      end
    end
  end