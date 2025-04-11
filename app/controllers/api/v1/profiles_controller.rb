# app/controllers/api/v1/profiles_controller.rb
module Api
    module V1
      class ProfilesController < ApiController
        before_action :set_profile
        
        def show
          render json: {
            status: 'success',
            data: {
              id: @profile.id,
              phone_num: @profile.phone_num,
              address: @profile.address,
              major: @profile.major,
              avatar_url: @profile.avatar.attached? ? url_for(@profile.avatar) : nil
            }
          }, status: :ok
        end
        
        def update_avatar
          if params[:avatar].present?
            @profile.avatar.attach(params[:avatar])
            
            render json: {
              status: 'success',
              message: 'Avatar uploaded successfully',
              data: {
                avatar_url: url_for(@profile.avatar)
              }
            }, status: :ok
          else
            render json: {
              status: 'error',
              message: 'No avatar file provided'
            }, status: :unprocessable_entity
          end
        end
        
        private
        
        def set_profile
          @profile = if params[:id]
            Profile.find(params[:id])
          else
            current_user.profile
          end
          
          # Authorize access
          unless current_user.admin? || @profile.user_id == current_user.id
            render json: {
              status: 'error',
              message: 'You can only access your own profile'
            }, status: :forbidden
            return
          end
        end
      end
    end
  end