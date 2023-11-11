# frozen_string_literal: true

# Say::LeftJustifier specializes on {Say::JustifierBehaviors} to provide
# left-justification of the given text, resulting in a String of the specified
# {Say::JustifierBehaviors#total_length}.
class Say::LeftJustifier
  include Say::JustifierBehaviors

  private

  def justify(text)
    text.ljust(justification_length, right_fill_pattern)
  end
end
