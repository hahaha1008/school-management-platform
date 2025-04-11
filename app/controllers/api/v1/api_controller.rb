# app/controllers/api/v1/api_controller.rb
module Api
    module V1
      class ApiController < ApplicationController
        # Skip default CSRF protection for APIs
        skip_before_action :verify_authenticity_token, if: :json_request?
        before_action :authenticate_api_user
        
        # Handle ActiveRecord errors
        rescue_from ActiveRecord::RecordNotFound, with: :not_found
        
        private
        
        def json_request?
          request.format.json? || request.headers["Content-Type"]&.include?('application/json')
        end
        
        def authenticate_api_user
          # Skip authentication for login and register endpoints
          return true if controller_name == 'authentication' && 
                       ['login', 'register'].include?(action_name)
          
          # Get token from Authorization header
          header = request.headers['Authorization']
          token = header.split(' ').last if header && header.start_with?('Bearer ')
          
          if token.present?
            begin
              decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')
              @current_user = User.find(decoded[0]['user_id'])
            rescue JWT::DecodeError, ActiveRecord::RecordNotFound => e
              Rails.logger.debug "Auth error: #{e.message}"
              render json: { 
                status: 'error', 
                message: 'Invalid or expired token' 
              }, status: :unauthorized
              return false
            end
          else
            Rails.logger.debug "No token provided"
            render json: { 
              status: 'error', 
              message: 'Authorization required' 
            }, status: :unauthorized
            return false
          end
        end
        
        def current_user
          @current_user
        end
        
        def not_found
          render json: {
            status: 'error',
            message: 'Record not found'
          }, status: :not_found
        end
      end
    end
  end