# Handles subscription checkout flow: validates plan selection, creates Stripe Checkout session,
# and redirects users to Stripe's payment page. After payment, both success and Stripe webhooks update the user's
# plan to 'pro' automatically.
class CheckoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_existing_subscription, only: [ :create ]
  before_action :load_plan

  # Pricing configuration moved to config/initializers/pricing_config.rb
  # This provides a single source of truth for pricing, features, and limits

  # POST /checkout
  # Creates a Stripe Checkout Session and redirects to Stripe"s hosted checkout page
  def create
    # Ensure user has a Stripe customer record
    current_user.set_payment_processor :stripe

    if @plan[:stripe_price_id].blank?
      redirect_to account_path, alert: "Stripe configuration is incomplete. Please contact support."
      nil
    end

    # Create a Stripe Checkout Session
    checkout_session = current_user.payment_processor.checkout(
      mode: "subscription",
      line_items: [
        {
          price: @plan[:stripe_price_id],
          quantity: 1
        }
      ],
      allow_promotion_codes: true,
      success_url: checkout_success_url(session_id: "{CHECKOUT_SESSION_ID}"),
      cancel_url: checkout_cancel_url,
      client_reference_id: current_user.id.to_s
    )

    # Redirect to Stripe's hosted checkout page
    redirect_to checkout_session.url, allow_other_host: true, status: :see_other
  rescue StandardError => e
    Rails.logger.error "Checkout error: #{e.message}"
    redirect_to account_path, alert: "Something went wrong. Please try again or contact support."
  end

  # GET /checkout/success
  # User returns here after successful payment on Stripe
  # In order for the change on plan be instant and not wait for the webhook, we do it in here
  # We still do it in the webhook just to be sure
  def success
    session_id = params[:session_id]

    if session_id.blank?
      flash[:alert] = "Invalid checkout session. Please contact support if you were charged."
      redirect_to account_path
      return
    end

    begin
      # Retrieve the checkout session from Stripe
      checkout_session = Stripe::Checkout::Session.retrieve(session_id)

      # Verify payment was successful
      if checkout_session.payment_status == "paid" && checkout_session.status == "complete"
        # Get the subscription ID from the session
        subscription_id = checkout_session.subscription

        if subscription_id
          # Sync the subscription using Pay gem
          pay_subscription = Pay::Stripe::Subscription.sync(subscription_id)

          if pay_subscription && pay_subscription.customer.owner.id == current_user.id
            # Update user plan immediately
            if [ "active", "trialing" ].include?(pay_subscription.status)
              current_user.update(plan: "pro")
              Rails.logger.info "User #{current_user.id} upgraded to pro plan via checkout success"
              flash[:success] = "Welcome to Pro! Your subscription is now active."
            else
              flash[:notice] = "Payment received. Your subscription will be activated shortly."
            end
          else
            flash[:alert] = "There was an issue activating your subscription. Please contact support."
          end
        else
          flash[:notice] = "Payment received. Your subscription is being processed."
        end
      else
        flash[:alert] = "Payment was not completed. Please try again or contact support."
      end
    rescue Stripe::InvalidRequestError => e
      Rails.logger.error "Invalid Stripe session #{session_id}: #{e.message}"
      flash[:alert] = "Invalid checkout session. Please contact support if you were charged."
    rescue StandardError => e
      Rails.logger.error "Error processing checkout success: #{e.message}"
      flash[:alert] = "There was an error processing your payment. Please contact support if you were charged."
    end

    redirect_to account_path
  end

  # GET /checkout/cancel
  # User returns here if they cancel or close the checkout page
  def cancel
    flash[:alert] = "Checkout cancelled. You can upgrade anytime from your account page."
    redirect_to account_path
  end


  private

  # Prevent users who already have an active subscription from creating another
  def check_existing_subscription
    if current_user.subscribed?
      redirect_to account_path, notice: "You already have an active Pro subscription."
    end
  end

  def load_plan
    interval = params[:interval]&.to_s&.downcase&.to_sym
    @plan = PricingConfig.get_plan(interval) || PricingConfig.get_plan(:monthly)
  end
end
