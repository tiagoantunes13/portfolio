module AiHelper
  def ai_chat(model: "gpt-5-nano-2025-08-07", provider: :open_ai)
    if Rails.env.production?
      RubyLLM.chat(
        model: model,
        provider: provider
      )
    else
      RubyLLM.chat(
        model: "qwen3:14b",
        provider: :ollama,
        assume_model_exists: true
      )
    end
  end

  def ai_chat_for_tools
    ai_chat(model: "gpt-4o-mini-2024-07-18")
  end

  def ai_chat_fast
    ai_chat(model: "gpt-5-nano-2025-08-07")
  end

  def ai_chat_smart
    ai_chat(model: "gpt-5-2025-08-07")
  end

  # Instructions to use in controller or job

  # response = ai_chat.ask("Hi, do this thing")
  # response = chat.with_schema(ExampleSchema).ask("Hi, do this thing")
  # chat.with_instructions(system_prompt)
  # chat.with_tools(
  #   jobs_tool,
  #   apps_tool,
  #   details_tool,
  #   get_cover_letter_tool,
  #   linkedin_tool,
  #   manual_job_tool,
  #   create_app_tool,
  #   cover_letter_tool,
  #   update_cover_letter_tool,
  #   remote_analysis_tool,
  #   job_fit_tool,
  #   update_app_tool,
  # )
  # if response&.content.present?
  #   use response.content
  # end
end
