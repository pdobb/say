# frozen_string_literal: true

# Say::RightJustifier specializes on {Say::JustifierBehaviors} to provide
# right-justification of the given text, resulting in a String of the specified
# {Say::JustifierBehaviors#total_length}.
class Say::RightJustifier
  include Say::JustifierBehaviors

  private

  def justify(text)
    text.rjust(justification_length, left_fill_pattern)
  end
end
