# frozen_string_literal: true

# Say::CenterJustifier specializes on {Say::JustifierBehaviors} to provide
# center-justification of the given text, resulting in a String of the specified
# {Say::JustifierBehaviors#total_length}.
class Say::CenterJustifier
  include Say::JustifierBehaviors

  private

  def justify(text)
    text.
      rjust(left_justification_length(text.length), left_fill_pattern).
      ljust(justification_length, right_fill_pattern)
  end

  def left_justification_length(text_length)
    (total_length / 2.0).ceil + (text_length / 2.0).ceil - left_bookend_length
  end
end
