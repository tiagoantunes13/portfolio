# == Schema Information
#
# Table name: contact_messages
#
#  id         :bigint           not null, primary key
#  email      :string
#  message    :text
#  name       :string
#  status     :string
#  subject    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ContactMessage < ApplicationRecord
  enum :status, { pending: "pending", read: "read", responded: "responded", archived: "archived" }

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, presence: true
  validates :message, presence: true

  after_initialize :set_default_status, if: :new_record?

  after_create :send_notification

  private

  def send_notification
    ContactMailer.new_contact_message(self).deliver_later
  end

  def set_default_status
    self.status ||= :pending
  end
end
