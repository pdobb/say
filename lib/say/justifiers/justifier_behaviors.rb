# frozen_string_literal: true

# Say::JustifierBehaviors is a mix-in that defines common
# left/center/right-justification behaviors.
#
# @see Say::LeftJustifier
# @see Say::CenterJustifier
# @see Say::RightJustifier
#
# :reek:ModuleInitialize
module Say::JustifierBehaviors
  DEFAULT_FILL_PATTERN = " "
  DEFAULT_LENGTH = Say::MAX_COLUMNS

  attr_reader :interpolation_template,
              :total_length

  # @param interpolation_template [Say::InterpolationTemplate]
  # @param length [Integer] how long the output String should aim to be, at
  #   most. Will not truncate.
  def initialize(interpolation_template:, length: DEFAULT_LENGTH)
    @interpolation_template = interpolation_template
    @total_length = Integer(length)
  end

  # Justify the given {#text} and wrap with left/right bookends. If a block is
  # given, then this will override anything passed by the `text` attribute.
  #
  # @return [String]
  def call(text = "")
    text = String(yield) if block_given?
    wrapped_text = interpolation_template.wrap(text)

    [
      left_bookend,
      justify(wrapped_text),
      right_bookend,
    ].join
  end

  private

  # :reek:UnusedParameters
  def justify(text)
    raise NotImplementedError
  end

  def justification_length
    total_length_excluding_bookends =
      total_length - left_bookend_length - right_bookend_length

    [total_length_excluding_bookends, 0].max
  end

  def left_fill_pattern
    left_fill? ? left_fill : DEFAULT_FILL_PATTERN
  end

  def right_fill_pattern
    right_fill? ? right_fill : DEFAULT_FILL_PATTERN
  end

  # rubocop:disable Style/SingleLineMethods
  def left_bookend; interpolation_template.left_bookend end
  def left_bookend_length; left_bookend.length end
  def left_fill; interpolation_template.left_fill end
  def left_fill?; interpolation_template.left_fill? end
  def right_bookend; interpolation_template.right_bookend end
  def right_bookend_length; right_bookend.length end
  def right_fill; interpolation_template.right_fill end
  def right_fill?; interpolation_template.right_fill? end
  # rubocop:enable Style/SingleLineMethods
end
