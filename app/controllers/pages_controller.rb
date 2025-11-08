class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  layout "landing"

  before_action :redirect_to_inside

  def landing
  end

  def pricing
  end

  def about
  end

  def contact
    @contact_message = ContactMessage.new
  end

  def privacy
  end

  def terms_of_service
  end

  private

  def redirect_to_inside
    redirect_to account_path if user_signed_in?
  end
end
