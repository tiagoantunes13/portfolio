ActiveSupport.on_load(:pay) do
  # When a new subscription is created - grant pro access
  Pay::Webhooks.delegator.subscribe "stripe.customer.subscription.created" do |event|
    pay_subscription = Pay::Stripe::Subscription.sync(event.data.object.id, stripe_account: event.try(:account))

    # Skip if subscription doesn't belong to this app (filters out other apps on same Stripe account)
    unless pay_subscription
      Rails.logger.info "Webhook: Subscription created event for unknown subscription #{event.data.object.id} - skipping (likely from another app)"
      next
    end

    user = pay_subscription.customer.owner
    status = pay_subscription.status

    Rails.logger.info "Webhook: Subscription created for user #{user.id}, status: #{status}"

    # Grant pro access if subscription is active or in trial
    if [ "active", "trialing" ].include?(status)
      user.update(plan: "pro")
      Rails.logger.info "Webhook: User #{user.id} upgraded to pro plan"
    end
  end

  # When subscription is updated - handle all status changes
  # This covers: renewals, cancellations, payment failures, plan changes, etc.
  Pay::Webhooks.delegator.subscribe "stripe.customer.subscription.updated" do |event|
    pay_subscription = Pay::Stripe::Subscription.sync(event.data.object.id, stripe_account: event.try(:account))

    unless pay_subscription
      Rails.logger.info "Webhook: Subscription updated event for unknown subscription #{event.data.object.id} - skipping"
      next
    end

    user = pay_subscription.customer.owner
    status = pay_subscription.status

    Rails.logger.info "Webhook: Subscription updated for user #{user.id}, new status: #{status}"

    # Update user plan based on subscription status
    # Keep access during "past_due" (grace period while Stripe retries payment)
    if [ "active", "trialing", "past_due" ].include?(status)
      user.update(plan: "pro")
      Rails.logger.info "Webhook: User #{user.id} has pro access (status: #{status})"
    elsif [ "canceled", "unpaid", "incomplete", "incomplete_expired" ].include?(status)
      user.update(plan: "free")
      Rails.logger.info "Webhook: User #{user.id} downgraded to free plan (status: #{status})"
    end
  end

  # When subscription is deleted - revoke pro access
  # This is the final cleanup when subscription ends
  Pay::Webhooks.delegator.subscribe "stripe.customer.subscription.deleted" do |event|
    pay_subscription = Pay::Stripe::Subscription.sync(event.data.object.id, stripe_account: event.try(:account))

    unless pay_subscription
      Rails.logger.info "Webhook: Subscription deleted event for unknown subscription #{event.data.object.id} - skipping"
      next
    end

    user = pay_subscription.customer.owner

    Rails.logger.info "Webhook: Subscription deleted for user #{user.id}"

    # Revoke pro access
    user.update(plan: "free")
    Rails.logger.info "Webhook: User #{user.id} downgraded to free plan"
  end
end
