class AccountsController < ApplicationController
  def show
    @plans = PricingConfig::PLANS
  end
end
