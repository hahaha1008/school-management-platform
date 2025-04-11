# app/controllers/api/v1/courses_controller.rb
module Api
    module V1
      class CoursesController < ApiController
        before_action :set_course, only: [:show]
        
        # GET /api/v1/courses
        def index
          if current_user.student?
            # Get courses the student is enrolled in
            @courses = current_user.courses.includes(:instructor)
          elsif current_user.instructor?
            # Get courses taught by the instructor
            @courses = current_user.taught_courses
          else
            # Admin gets all courses
            @courses = Course.all.includes(:instructor)
          end
          
          render json: { status: 'success', data: @courses.as_json(only: [:id, :course_name, :term], 
                       include: { instructor: { only: :user_name } }) }
        end
        
        # GET /api/v1/courses/:id
        def show
          # Check if student is enrolled or user is instructor/admin
          if current_user.student? && !current_user.courses.include?(@course)
            render json: {
              status: 'error',
              message: 'You are not enrolled in this course'
            }, status: :forbidden
            return
          end
          
          # Include assignments in response
          assignments = @course.assignments.order(due_date: :asc)
          
          render json: {
            status: 'success',
            data: course_to_json(@course).merge({
              description: @course.description,
              assignments: assignments.map { |assignment|
                {
                  id: assignment.id,
                  title: assignment.ass_title,
                  due_date: assignment.due_date,
                  has_submitted: current_user.student? ? 
                    assignment.submissions.exists?(user_id: current_user.id) : nil
                }
              }
            })
          }, status: :ok
        end
        
        private
        
        def set_course
          @course = Course.find(params[:id])
        end
        
        def course_to_json(course)
          {
            id: course.id,
            name: course.course_name,
            term: course.term,
            instructor: course.instructor.user_name
          }
        end
      end
    end
  end