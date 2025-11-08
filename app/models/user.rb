# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  last_name              :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  plan                   :string           default("free"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  # User first_name and last_name already included but not in views and no validation, add if needed
  # validates :first_name, presence: true
  # validates :last_name, presence: true

  enum :plan, { free: "free", pro: "pro" }

  # Include usage tracking
  include TrackableUsage

  # Add Pay
  pay_customer

  def name
    "#{first_name} #{last_name}".strip
  end

  # =========================================
  # PLAN & SUBSCRIPTION METHODS
  # =========================================

  # Verified checks (checks actual subscription status)
  def subscribed?
    pro? && has_active_subscription?
  end

  def has_active_subscription?
    pay_subscriptions.active.any? ||
    pay_subscriptions.on_trial.any? ||
    pay_subscriptions.on_grace_period.any?
  end

  def subscription
    payment_processor.subscription
  rescue StandardError
    nil
  end

  # =========================================
  # FEATURE METHODS
  # =========================================

  # On the concern
end
