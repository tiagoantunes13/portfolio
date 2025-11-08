class BaseActionTool < BaseTool
  def with_feature_gate(event_type, &block)
    # Check if user can use this feature
    error = check_feature_gate(event_type)
    return error if error

    # Execute the action
    result = yield

    # Track usage if successful
    track_usage(event_type) if result[:success]

    result
  end


  private

  # Check if user can perform a feature-gated action
  # Returns error_response if not allowed, nil if allowed
  def check_feature_gate(event_type)
    unless @user.can_use?(event_type)
      return error_response("You have no more credits left to do this operation")
    end
    nil
  end

  # Track successful usage of a feature
  def track_usage(event_type)
    @user.track_usage(event_type)
  end
end
