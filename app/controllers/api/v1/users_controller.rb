# app/controllers/api/v1/users_controller.rb
module Api
    module V1
      class UsersController < ApiController
        before_action :set_user, only: [:show, :update]
        before_action :authorize_user, only: [:update]
        
        # GET /api/v1/users/:id
        def show
          render json: {
            status: 'success',
            data: {
              id: @user.id,
              user_name: @user.user_name,
              role: @user.role,
              created_at: @user.created_at,
              profile: @user.profile.present? ? {
                major: @user.profile.major,
                phone_num: @user.profile.phone_num,
                address: @user.profile.address,
                avatar_url: @user.profile.avatar.attached? ?
                  url_for(@user.profile.avatar) : nil
              } : nil
            }
          }, status: :ok
        end
        
        # PATCH/PUT /api/v1/users/:id
        def update
          @user.assign_attributes(user_params.except(:profile_attributes))
          
          if params[:user][:profile_attributes].present? && params[:user][:profile_attributes][:avatar].present?
            @user.profile.avatar.purge if @user.profile.avatar.attached?
            # Add analyze: false to prevent background job creation
            @user.profile.avatar.attach(params[:user][:profile_attributes][:avatar], analyze: false)
          end
          
          if @user.save
            render json: {
              status: 'success',
              message: 'Profile successfully updated',
              data: {
                id: @user.id,
                user_name: @user.user_name,
                role: @user.role
              }
            }, status: :ok
          else
            render json: {
              status: 'error',
              message: 'Update failed',
              errors: @user.errors.full_messages
            }, status: :unprocessable_entity
          end
        end
        
        private
        
        def set_user
          @user = User.find(params[:id])
        end
        
        def authorize_user
          unless current_user.id == @user.id || current_user.admin?
            render json: {
              status: 'error',
              message: 'You can only update your own profile'
            }, status: :forbidden
          end
        end
        
        def user_params
          params.require(:user).permit(
            :user_name,
            :password,
            :role,
            :expire_date,
            profile_attributes: [:id, :phone_num, :address, :major, :avatar]
          )
        end
      end
    end
  end