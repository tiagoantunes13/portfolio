
class ExampleSchema < RubyLLM::Schema
  string :veridict, enum: [ "remote", "onsite", "hybrid", "unsure" ], description: "Indicates if the job is remote, onsite, hybrid, or unsure"
  string :explanation, description: "A brief explanation of the veridict, why it is classified as such"
  integer :confidence_score,
            description: "Confidence level from 0-100."
end
