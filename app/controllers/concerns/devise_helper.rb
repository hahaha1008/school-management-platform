# app/controllers/concerns/devise_helper.rb
module DeviseHelper
    extend ActiveSupport::Concern
  
    included do
      if respond_to?(:before_action)
        before_action :configure_permitted_parameters, if: :devise_controller?
      end
    end
  
    protected
  
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:user_name, :role])
      devise_parameter_sanitizer.permit(:account_update, keys: [:user_name])
    end
  end