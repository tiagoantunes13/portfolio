class ExampleTool < BaseActionTool
  description "This is the description of the tool"

  param :name, type: :string, desc: "Name of the user"
  param :email, type: :string, desc: "Email of the user"

  def execute(name:, email:)
    with_feature_gate(:ai_generation) do
      # This only runs if user has credits
      result = generate_ai_content(prompt)

      success_response(content: result)
    end
  end

  private

  def generate_ai_content(prompt)
    if true
      success_response(
        {
          id: job.id,
          title: job.title,
          company: job.company,
          location: job.location,
          source: job.source,
          has_description: job.description.present?
        },
        "Successfully imported and saved #{job.title} at #{job.company}"
      )
    else
      error_response(
        "Failed to save the job",
        job.errors.full_messages
      )
    end
  end
end
