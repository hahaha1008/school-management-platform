# app/controllers/api/v1/authentication_controller.rb
module Api
    module V1
      class AuthenticationController < ApiController
        # Skip authentication for login and register
        skip_before_action :authenticate_api_user, only: [:login, :register]
        
        # POST /api/v1/login
        def login
          user_name = params[:user_name] || params.dig(:authentication, :user_name)
          password = params[:password] || params.dig(:authentication, :password)
          
          user = User.find_by(user_name: user_name)
          
          Rails.logger.debug "Using username: #{user_name}"
          Rails.logger.debug "Using password: #{password}"
          Rails.logger.debug "Found user: #{user.inspect}" if user
          
          # Change this line to use Devise's valid_password? method
          if user && user.valid_password?(password)
            token = generate_jwt_token(user)
            
            render json: {
              status: 'success',
              message: 'Logged in successfully',
              data: {
                user_id: user.id,
                user_name: user.user_name,
                role: user.role,
                token: token
              }
            }, status: :ok
          else
            render json: {
              status: 'error',
              message: 'Invalid username or password'
            }, status: :unauthorized
          end
        end
        
        # POST /api/v1/register
        def register
          user = User.new(
            user_name: params[:user_name],
            email: params[:email] || "#{params[:user_name]}@example.com", # Ensure email is set
            password: params[:password],
            role: 'student', # Default to student role for API registrations
            expire_date: 1.year.from_now
          )
          
          if user.save
            # Create profile
            user.create_profile(
              phone_num: params[:phone_num] || '',
              address: params[:address] || '',
              major: params[:major] || ''
            )
            
            token = generate_jwt_token(user)
            
            render json: {
              status: 'success',
              message: 'User registered successfully',
              data: {
                user_id: user.id,
                user_name: user.user_name,
                role: user.role,
                token: token
              }
            }, status: :created
          else
            render json: {
              status: 'error',
              message: 'Registration failed',
              errors: user.errors.full_messages
            }, status: :unprocessable_entity
          end
        end
        
        private
        
        def generate_jwt_token(user)
          payload = {
            user_id: user.id,
            exp: 24.hours.from_now.to_i
          }
          JWT.encode(payload, Rails.application.secret_key_base)
        end
      end
    end
  end