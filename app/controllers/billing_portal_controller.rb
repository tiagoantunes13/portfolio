# Manages user billing and subscriptions: provides access to Stripe's Customer Portal where
# users can cancel subscriptions, update payment methods, and view invoices.
class BillingPortalController < ApplicationController
  before_action :authenticate_user!
  before_action :require_subscription

  # POST /billing_portal
  # Creates a Stripe Billing Portal session and redirects to Stripe's hosted portal
  # where users can update payment method, view invoices, or cancel subscription
  def create
    portal_session = current_user.payment_processor.billing_portal(
      return_url: account_url
    )

    redirect_to portal_session.url, allow_other_host: true, status: :see_other
  rescue StandardError
    redirect_to account_path, alert: "Unable to access billing portal. Please try again or contact support."
  end

  private

  # Ensure user has an active subscription before accessing billing portal
  def require_subscription
    unless current_user.subscribed?
      redirect_to account_path, alert: "You need an active subscription to access the billing portal."
    end
  end
end
