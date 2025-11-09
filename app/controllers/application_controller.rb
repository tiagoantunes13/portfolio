class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  layout :determine_layout

  include AiHelper
  helper_method :ai_chat  # Makes it available in views too

  private

  def determine_layout
    if devise_controller?
      # Edit/update actions use application layout (user is logged in)
      if action_name == "edit" || action_name == "update"
        "application"
      else
        # Sign in, sign up, password reset, etc. use landing layout
        "landing"
      end
    else
      "application"
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name ])
  end
end
