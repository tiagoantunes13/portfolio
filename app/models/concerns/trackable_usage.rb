module TrackableUsage
  extend ActiveSupport::Concern

  included do
    has_many :usage_events, dependent: :destroy
  end

  # In controllers just use:
  # current_user.can_use?(:cover_letter) to check, this will check based on its plan and all
  # current_user.track_usage(:cover_letter) to track the usage of it
  # the rest are good and i can use but these 2 are the most common i think

  # Feature limits are now defined in config/initializers/pricing_config.rb
  # This provides a single source of truth for pricing, features, and limits

  # Track usage of a feature
  # feature - Feature name (from UsageEvent.event_type)
  # count - How many times feature was used
  # metadata - Optional additional data
  def track_usage(feature, count: 1, metadata: {})
    usage_events.create!(
      feature: feature,
      count: count,
      metadata: metadata
    )
  end

  # Get current usage for a feature
  # feature - Feature name
  def usage_for(feature)
    scope = usage_events.where(feature: feature)
    scope.sum(:count)
  end

  # Get the limit for a feature based on user's plan
  # feature - Feature name
  def limit_for(feature)
    # Map feature name to PricingConfig feature key
    feature_key = PricingConfig::FEATURE_KEYS[feature.to_sym] || feature.to_sym
    PricingConfig.feature_limit(plan, feature_key)
  end

  # Check if user can use a feature
  # feature - Feature name
  def can_use?(feature, count: 1)
    limit = limit_for(feature)
    return true if limit == Float::INFINITY

    usage_for(feature) + count <= limit
  end

  # Get remaining usage for a feature
  # feature - Feature name
  def remaining_usage(feature, period: :month)
    limit = limit_for(feature)
    return Float::INFINITY if limit == Float::INFINITY

    [ limit - usage_for(feature), 0 ].max
  end
end
