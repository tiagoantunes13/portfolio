class PagesController < ApplicationController
  layout "landing"

  # No longer needed for portfolio
  # before_action :redirect_to_inside

  def landing
    @projects = Project.featured.ordered
  end

  # def pricing
  # end

  def about
  end

  def contact
    @contact_message = ContactMessage.new
  end

  # def privacy
  # end

  # def terms_of_service
  # end

  # private

  # def redirect_to_inside
  #   redirect_to account_path if user_signed_in?
  # end
end
