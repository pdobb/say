# frozen_string_literal: true

# :reek:TooManyInstanceVariables
# :reek:DataClump

# Say::InterpolationTemplate is a value object that represents an
# interpolation template for interpolating text and creating banners of a
# specified length.
#
# Each segment of the interpolation template affects the output string as
# specified:
# - {#left_bookend} always anchored to left side of the output string; does
#   not factor into string length for justification purposes.
# - {#left_fill} the repeatable portion of the string to the left of the spacer
#   and the given text.
# - {#left_spacer} a static string inserted to the left of the given text.
# - `text` is the given text that is to be interpolated into the template.
# - {#right_spacer} a static string inserted to the right of the given text.
# - {#right_fill} the repeatable portion of the string to the right of the
#   spacer and the given text.
# - {#right_bookend} always anchored to right side of the output string; does
#   not factor into string length for justification purposes.
#
# @example Default Template
#   interpolation_template = Say::InterpolationTemplate.new
#   interpolation_template.interpolate("TEST")  # => "TEST"
#
# @example Custom Template
#   interpolation_template =
#     Say::InterpolationTemplate.new(
#       left_bookend: "LBE",
#       left_fill: "<",
#       left_spacer: " ",
#       right_spacer: " ",
#       right_fill: ">",
#       right_bookend: "RBE")
#   interpolation_template.interpolate("TEST")  # => "LBE< TEST >RBE"
#
# @see Say::InterpolationTemplate::Builder Say::InterpolationTemplate::Builder
#   -- for built-in/pre-defined templates.
class Say::InterpolationTemplate
  # A symbolic representation of the portion of the interpolation template
  # string that should be replaced with the given `text` during interpolation.
  INTERPOLATION_SENTINEL = "{}"

  attr_reader :left_bookend,
              :left_fill,
              :left_spacer,
              :right_spacer,
              :right_fill,
              :right_bookend

  # rubocop:disable Metrics/ParameterLists
  # :reek:LongParameterList
  # :reek:TooManyStatements

  def initialize(
        left_bookend: nil,
        left_fill: nil,
        left_spacer: nil,
        right_spacer: nil,
        right_fill: nil,
        right_bookend: nil)
    @left_bookend = String(left_bookend).freeze
    @left_fill = String(left_fill).freeze
    @left_spacer = String(left_spacer).freeze
    @right_spacer = String(right_spacer).freeze
    @right_fill = String(right_fill).freeze
    @right_bookend = String(right_bookend).freeze
  end
  # rubocop:enable Metrics/ParameterLists

  # All attributes needed to represent the initialization of this object.
  #
  # @return [Hash]
  def to_h
    {
      left_bookend: left_bookend,
      left_fill: left_fill,
      left_spacer: left_spacer,
      right_spacer: right_spacer,
      right_fill: right_fill,
      right_bookend: right_bookend,
    }
  end
  alias_method :attributes, :to_h

  # A "template"-style String representation of all attributes in this object.
  #
  # @return [String]
  def inspect
    [
      left_bookend,
      (left_fill? ? "['#{left_fill}', ...]" : ""),
      left_spacer,
      INTERPOLATION_SENTINEL,
      right_spacer,
      (right_fill? ? "['#{right_fill}', ...]" : ""),
      right_bookend,
    ].join
  end

  # Apply direct interpolation of the given `text`, ignorant of any target
  # lengths (ignoring repetition of left/right fills).
  #
  # @return [String]
  def interpolate(text = "")
    [
      left_bookend,
      left_fill,
      left_spacer,
      text,
      right_spacer,
      right_fill,
      right_bookend,
    ].join
  end

  # Output a left-justified banner of the given `length`.
  #
  # @param text [String]
  # @param length [Integer]
  #
  # @return [String]
  def left_justify(text = "", length: Say::MAX_COLUMNS)
    justifier =
      Say::LeftJustifier.new(interpolation_template: self, length: length)
    justifier.call(text)
  end

  # Output a center-justified banner of the given `length`.
  #
  # @param text [String]
  # @param length [Integer]
  #
  # @return [String]
  def center_justify(text = "", length: Say::MAX_COLUMNS)
    justifier =
      Say::CenterJustifier.new(interpolation_template: self, length: length)
    justifier.call(text)
  end

  # Output a right-justified banner of the given `length`.
  #
  # @param text [String]
  # @param length [Integer]
  #
  # @return [String]
  def right_justify(text = "", length: Say::MAX_COLUMNS)
    justifier =
      Say::RightJustifier.new(interpolation_template: self, length: length)
    justifier.call(text)
  end

  # Wrap the given `text` with the {#left_spacer} and {#right_spacer}.
  #
  # @return [String]
  def wrap(text)
    [
      left_fill,
      left_spacer,
      text,
      right_spacer,
      right_fill,
    ].join
  end

  # Presence check for {#left_fill}.
  #
  # @return [True, False]
  def left_fill?
    left_fill != ""
  end

  # Presence check for {#right_fill}.
  #
  # @return [True, False]
  def right_fill?
    right_fill != ""
  end

  # Say::InterpolationTemplate::Builder is a factory for creating
  # Say::InterpolationTemplate objects from the given type name or template
  # attributes.
  #
  # The default Interpolation Template class is {Say::InterpolationTemplate}.
  module Builder
    # The default Predefined Interpolation Template to use, if no other name is
    # provided.
    DEFAULT_INTERPOLATION_TEMPLATE_NAME = :title

    # Predefined Interpolation Templates by name and attributes hash.
    DEFAULT_INTERPOLATION_TEMPLATES = {
      DEFAULT_INTERPOLATION_TEMPLATE_NAME => {
        left_fill: "=", left_spacer: " ", right_spacer: " ", right_fill: "="
      },
      hr: {
        left_fill: "=", right_fill: "="
      },
      wtf: {
        left_fill: "?", left_spacer: " ", right_spacer: " ", right_fill: "?"
      },
    }.freeze

    # rubocop:disable Style/CommentedKeyword
    DEFAULT_INTERPOLATION_TEMPLATES.each_key do |type_name|
      define_singleton_method(type_name) do   # def self.<type_name>
        call(type_name)                       #   call(<type_name))
      end                                     # end
    end
    # rubocop:enable Style/CommentedKeyword

    # @param type_or_template [#to_sym, `interpolation_template_class`] A type
    #   name -- representing a set of interpolation template attributes.
    #   Or, an object of type `interpolation_template_class` -- to be passed
    #   through untouched.
    def self.call(
          type_or_template = nil,
          interpolation_template_class: Say::InterpolationTemplate)
      if type_or_template.is_a?(interpolation_template_class)
        return type_or_template
      end

      interpolation_template_attributes =
        to_interpolation_template_attributes(
          type_or_template || DEFAULT_INTERPOLATION_TEMPLATE_NAME)
      interpolation_template_class.new(**interpolation_template_attributes)
    end

    # @param type_name_or_template_attributes [#to_sym] One of
    #   `DEFAULT_INTERPOLATION_TEMPLATES.keys`.
    def self.to_interpolation_template_attributes(
          type_name_or_template_attributes)
      case type_name_or_template_attributes
      when Hash
        type_name_or_template_attributes
      else
        DEFAULT_INTERPOLATION_TEMPLATES.fetch(
          type_name_or_template_attributes.to_sym)
      end
    end
  end

  # rubocop:disable all
  # :nocov:
  # @!visibility private

  # Usage: Say::InterpolationTemplate.test;
  def self.test
    Say.("Say::InterpolationTemplate.test") do
      interpolation_template_attributes_set = [
        Say::InterpolationTemplate::Builder.call.to_h,
        { left_fill: "=" },
        { right_fill: "=" },
        { left_bookend: "( •_•)O*¯", left_fill: "`·.·´", right_fill: "`·.·´", right_bookend: "¯°Q(•_• )" },
        { left_bookend: "╰(⇀︿⇀)つ-]═", left_fill: "-", right_fill: "-" },
      ]

      results =
        interpolation_template_attributes_set.map { |interpolation_template_attributes|
          interpolation_template = new(**interpolation_template_attributes)

          {
            inspect: interpolation_template.inspect,
            interpolate: interpolation_template.interpolate("TEST"),
            left_justify: interpolation_template.left_justify("TEST"),
            center_justify: interpolation_template.center_justify("TEST"),
            right_justify: interpolation_template.right_justify("TEST"),
          }
        }

      expected_results = [
        {
          inspect:        "['=', ...] {} ['=', ...]",
          interpolate:    "= TEST =",
          left_justify:   "= TEST =========================================================================",
          center_justify: "===================================== TEST =====================================",
          right_justify:  "========================================================================= TEST =",
        },
        {
          inspect:        "['=', ...]{}",
          interpolate:    "=TEST",
          left_justify:   "=TEST                                                                           ",
          center_justify: "=======================================TEST                                     ",
          right_justify:  "============================================================================TEST",
        },
        {
          inspect:        "{}['=', ...]",
          interpolate:    "TEST=",
          left_justify:   "TEST============================================================================",
          center_justify: "                                      TEST======================================",
          right_justify:  "                                                                           TEST=",
        },
        {
          inspect:        "( •_•)O*¯['`·.·´', ...]{}['`·.·´', ...]¯°Q(•_• )",
          interpolate:    "( •_•)O*¯`·.·´TEST`·.·´¯°Q(•_• )",
          left_justify:   "( •_•)O*¯`·.·´TEST`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.¯°Q(•_• )",
          center_justify: "( •_•)O*¯`·.·´`·.·´`·.·´`·.·´`·.·`·.·´TEST`·.·´`·.·´`·.·´`·.·´`·.·´`·.·¯°Q(•_• )",
          right_justify:  "( •_•)O*¯`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.·´`·.`·.·´TEST`·.·´¯°Q(•_• )",
        },
        {
          inspect:        "╰(⇀︿⇀)つ-]═['-', ...]{}['-', ...]",
          interpolate:    "╰(⇀︿⇀)つ-]═-TEST-",
          left_justify:   "╰(⇀︿⇀)つ-]═-TEST-----------------------------------------------------------------",
          center_justify: "╰(⇀︿⇀)つ-]═----------------------------TEST--------------------------------------",
          right_justify:  "╰(⇀︿⇀)つ-]═-----------------------------------------------------------------TEST-",
        },
      ]

      if results == expected_results
        ap({ "✅" => results })
      else
        ap({ "❌" => { "Got:" => results, "Expected:" => expected_results } })
      end
    end
  end

  # :nocov:
  # rubocop:enable all
end
