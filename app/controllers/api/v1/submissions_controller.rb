# app/controllers/api/v1/submissions_controller.rb
module Api
    module V1
      class SubmissionsController < ApiController
        before_action :set_course_and_assignment
        before_action :set_submission, only: [:show, :update]
        before_action :authorize_access
        
        # GET /api/v1/courses/:course_id/assignments/:assignment_id/submissions/:id
        def show
          render json: {
            status: 'success',
            data: {
              id: @submission.id,
              assignment_id: @assignment.id,
              course_id: @course.id,
              student_id: @submission.user_id,
              student_name: @submission.user.user_name,
              submit_time: @submission.submit_time,
              grade: @submission.grade,
              content: @submission.content
            }
          }, status: :ok
        end
        
        # POST /api/v1/courses/:course_id/assignments/:assignment_id/submissions
        def create
          # Only students can create submissions
          unless current_user.student?
            render json: {
              status: 'error',
              message: 'Only students can submit assignments'
            }, status: :forbidden
            return
          end
          
          # Check if already submitted
          if @assignment.submissions.exists?(user_id: current_user.id)
            render json: {
              status: 'error',
              message: 'You have already submitted this assignment'
            }, status: :unprocessable_entity
            return
          end
          
          @submission = @assignment.submissions.build(
            user: current_user,
            content: params[:content],
            submit_time: Time.current
          )
          
          if @submission.save
            render json: {
              status: 'success',
              message: 'Assignment successfully submitted',
              data: {
                id: @submission.id,
                assignment_id: @assignment.id,
                submit_time: @submission.submit_time
              }
            }, status: :created
          else
            render json: {
              status: 'error',
              message: 'Submission failed',
              errors: @submission.errors.full_messages
            }, status: :unprocessable_entity
          end
        end
        
        # PATCH/PUT /api/v1/courses/:course_id/assignments/:assignment_id/submissions/:id
        def update
          # Students can update their own submissions before grading
          if current_user.student?
            unless @submission.user_id == current_user.id && @submission.grade.nil?
              render json: {
                status: 'error',
                message: 'You cannot update this submission'
              }, status: :forbidden
              return
            end
            
            if @submission.update(content: params[:content], submit_time: Time.current)
              render json: {
                status: 'success',
                message: 'Submission updated successfully',
                data: {
                  id: @submission.id,
                  submit_time: @submission.submit_time
                }
              }, status: :ok
            else
              render json: {
                status: 'error',
                message: 'Update failed',
                errors: @submission.errors.full_messages
              }, status: :unprocessable_entity
            end
          # Instructors can grade submissions
          elsif current_user.instructor? || current_user.admin?
            if @submission.update(grade: params[:grade])
              render json: {
                status: 'success',
                message: 'Submission graded successfully',
                data: {
                  id: @submission.id,
                  grade: @submission.grade
                }
              }, status: :ok
            else
              render json: {
                status: 'error',
                message: 'Grading failed',
                errors: @submission.errors.full_messages
              }, status: :unprocessable_entity
            end
          end
        end

        def destroy
            @submission = @assignment.submissions.find_by(id: params[:id])
            
            if @submission.nil?
              render json: {
                status: 'error',
                message: 'Submission not found'
              }, status: :not_found
              return
            end
            
            # Only allow students to delete their own ungraded submissions or admins to delete any
            if (current_user.student? && @submission.user_id == current_user.id && @submission.grade.nil?) || 
               current_user.admin?
               
              if @submission.destroy
                render json: {
                  status: 'success',
                  message: 'Submission deleted successfully'
                }, status: :ok
              else
                render json: {
                  status: 'error',
                  message: 'Failed to delete submission'
                }, status: :unprocessable_entity
              end
            else
              render json: {
                status: 'error',
                message: 'You are not authorized to delete this submission'
              }, status: :forbidden
            end
          end
        
          
          def update
            # Students can update their own submissions before grading
            if current_user.student?
              unless @submission.user_id == current_user.id && @submission.grade.nil?
                render json: {
                  status: 'error',
                  message: 'You cannot update this submission'
                }, status: :forbidden
                return
              end
              
              if @submission.update(content: params[:content], submit_time: Time.current)
                render json: {
                  status: 'success',
                  message: 'Submission updated successfully',
                  data: {
                    id: @submission.id,
                    submit_time: @submission.submit_time
                  }
                }, status: :ok
              else
                render json: {
                  status: 'error',
                  message: 'Update failed',
                  errors: @submission.errors.full_messages
                }, status: :unprocessable_entity
              end
            # Instructors can grade submissions
            elsif current_user.instructor? || current_user.admin?
              old_grade = @submission.grade
              
              if @submission.update(grade: params[:grade])
                # Send email notification only if this is a new grade or grade has changed
                if old_grade != @submission.grade
                  NotificationMailer.grade_notification(@submission).deliver_later
                end
                
                render json: {
                  status: 'success',
                  message: 'Submission graded successfully',
                  data: {
                    id: @submission.id,
                    grade: @submission.grade
                  }
                }, status: :ok
              else
                render json: {
                  status: 'error',
                  message: 'Grading failed',
                  errors: @submission.errors.full_messages
                }, status: :unprocessable_entity
              end
            end
          end
        
        private
        
        def set_course_and_assignment
          @course = Course.find(params[:course_id])
          @assignment = @course.assignments.find(params[:assignment_id])
        end
        
        def set_submission
          @submission = if current_user.admin? || (@course.instructor_id == current_user.id)
            @assignment.submissions.find(params[:id])
          else
            @assignment.submissions.find_by!(user_id: current_user.id)
          end
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
      end
    end
  end