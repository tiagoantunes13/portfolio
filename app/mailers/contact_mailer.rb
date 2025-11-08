class ContactMailer < ApplicationMailer
  def new_contact_message(contact_message)
    @contact_message = contact_message
    mail(
      to: "tiagoantunes9991@gmail.com",
      subject: "New Contact Form: #{contact_message.subject}"
    )
  end
end
