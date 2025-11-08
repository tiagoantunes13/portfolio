class ContactMessagesController < ApplicationController
  skip_before_action :authenticate_user!
  layout "landing"

  def create
    @contact_message = ContactMessage.new(contact_message_params)
    if @contact_message.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("contact_form", partial: "pages/success_contact_form")
        end
        format.html { redirect_to contact_path, notice: "Your message has been sent successfully." }
      end
    else
      render "pages/contact", status: :unprocessable_entity
    end
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(:name, :email, :subject, :message)
  end
end
