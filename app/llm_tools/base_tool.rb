class BaseTool < RubyLLM::Tool
  def initialize(user)
    @user = user
  end

  private

  # Standardized success response for all tools
  def success_response(data, message)
    {
      success: true,
      data: data,
      message: message
    }
  end

  # Standardized error response for all tools
  def error_response(error, details = nil)
    response = {
      success: false,
      error: error
    }
    response[:details] = details if details
    response
  end
end
