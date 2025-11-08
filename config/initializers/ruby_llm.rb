RubyLLM.configure do |config|
  config.openai_api_key = Rails.application.credentials.open_ai_key
  config.gemini_api_key = Rails.application.credentials.dig(:gemini, :api_key)
  config.ollama_api_base = "http://localhost:11434/v1"

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true
end
