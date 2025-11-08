# Centralized pricing and plans configuration
module PricingConfig
  # All available plans with complete information
  PLANS = {
    free: {
      id: "free",
      name: "Free",
      display_name: "Free Plan",
      price: {
        amount: 0,
        currency: "EUR",
        display: "€0",
        interval: "month"
      },
      stripe_price_id: nil,
      features: {
        ai_cover_letters: { limit: 1, display: "1 AI cover letter per month", period: "month" },
        location_checks: { limit: 1, display: "1 location check per month", period: "month" },
        cv_imports: { limit: 1, display: "1 AI CV import", period: "lifetime" },
        job_searches: { limit: 1, display: "1 job search", period: "month" },
        linkedin_import: { limit: Float::INFINITY, display: "LinkedIn job import" },
        track_applications: { limit: Float::INFINITY, display: "Track unlimited applications" },
        ai_chat: { limit: 10, display: "AI Chat (trial)", period: "lifetime" }
      },
      cta: "Start Free",
      description: "Perfect for getting started",
      highlights: [
        "No credit card required",
        "Free forever",
        "Track unlimited applications"
      ]
    },

    monthly: {
      id: "monthly",
      name: "Pro",
      display_name: "Pro Monthly",
      price: {
        amount: 3,
        currency: "EUR",
        display: "€3",
        interval: "month"
      },
      stripe_price_id: "price_1SOnmZFGOj6omgHk1tjLSAay", # Update this to match €3/month in Stripe
      features: {
        ai_cover_letters: { limit: Float::INFINITY, display: "Unlimited AI cover letters" },
        location_checks: { limit: Float::INFINITY, display: "Unlimited location checks" },
        cv_imports: { limit: Float::INFINITY, display: "Unlimited AI CV imports" },
        job_searches: { limit: Float::INFINITY, display: "Job search access" },
        linkedin_import: { limit: Float::INFINITY, display: "LinkedIn job import" },
        save_jobs: { limit: Float::INFINITY, display: "Save unlimited jobs" },
        ai_chat: { limit: Float::INFINITY, display: "Unlimited AI Chat" },
        priority_support: { limit: Float::INFINITY, display: "Priority support" }
      },
      cta: "Get Started",
      description: "Billed monthly, cancel anytime"
    },

    annual: {
      id: "annual",
      name: "Pro",
      display_name: "Pro Annual",
      price: {
        amount: 19,
        currency: "EUR",
        display: "€19",
        interval: "year",
        monthly_equivalent: "€1.58"
      },
      stripe_price_id: "price_1SOnmuFGOj6omgHkOJho86ZL", # Update this to match €19/year in Stripe
      savings: {
        amount: 17,
        percent: 47,
        display: "Save 47%"
      },
      badge: "Best Value",
      features: {
        ai_cover_letters: { limit: Float::INFINITY, display: "Unlimited AI cover letters" },
        location_checks: { limit: Float::INFINITY, display: "Unlimited location checks" },
        cv_imports: { limit: Float::INFINITY, display: "Unlimited AI CV imports" },
        job_searches: { limit: Float::INFINITY, display: "Job search access" },
        linkedin_import: { limit: Float::INFINITY, display: "LinkedIn job import" },
        save_jobs: { limit: Float::INFINITY, display: "Save unlimited jobs" },
        ai_chat: { limit: Float::INFINITY, display: "Unlimited AI Chat" },
        priority_support: { limit: Float::INFINITY, display: "Priority support" }
      },
      cta: "Get Started",
      description: "Best value - Save €17/year!",
      is_recommended: true
    }
  }.freeze

  # Feature keys mapping for usage tracking
  FEATURE_KEYS = {
    cover_letter: :ai_cover_letters,
    location_check: :location_checks,
    cv_import: :cv_imports,
    job_search: :job_searches,
    linkedin_import: :linkedin_import,
    save_job: :save_jobs,
    ai_chat_message: :ai_chat
  }.freeze

  # Helper methods
  class << self
    # Get plan configuration by ID
    def get_plan(plan_id)
      PLANS[plan_id.to_sym]
    end

    # Get feature limit for a specific plan and feature
    def feature_limit(plan_id, feature_key)
      plan = get_plan(plan_id)
      return 0 unless plan

      feature = plan[:features][feature_key.to_sym]
      feature ? feature[:limit] : 0
    end

    # Get display price for a plan
    def display_price(plan_id, include_interval: true)
      plan = get_plan(plan_id)
      return "" unless plan

      price = plan[:price][:display]
      return price unless include_interval && plan[:price][:interval]

      "#{price}/#{plan[:price][:interval]}"
    end

    # Get feature list for a plan as array of strings
    def feature_list(plan_id)
      plan = get_plan(plan_id)
      return [] unless plan

      plan[:features].values.map { |f| f[:display] }
    end
  end
end
