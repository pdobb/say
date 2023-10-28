# frozen_string_literal: true

# Say::InterpolationTemplate is a value object that assigns meaning to the
# passed in `interpolation_template_string` and exposes useful API methods for
# interrogating it.
#
# The default `interpolation_sentinel` is `"{}"`.
# The default `interpolation_template_string` is: `"{}"` (i.e. no flourishes
# are added on top of the default interpolation sentinel, in an attempt to be
# neutral or to "know nothing" about "preferred" use cases.)
#
# The "interpolation sentinel" indicates the portion of the interpolation
# template string that should be replaced with the given `text` during
# interpolation.
#
# @example Default Template
#   interpolation_template = Say::InterpolationTemplate.new
#   interpolation_template.interpolate("TEST")  # => "TEST="
#
# @example Custom Template
#   interpolation_template = Say::InterpolationTemplate.new("=~{}~=")
#   interpolation_template.interpolate("TEST")  # => "=~TEST~="
class Say::InterpolationTemplate
  # The default interpolation sentinel used for interpolation templates.
  DEFAULT_INTERPOLATION_SENTINEL = "{}"

  # The default interpolation template, using the default interpolation
  # sentinel.
  # rubocop:disable Style/RedundantInterpolation
  DEFAULT_INTERPOLATION_TEMPLATE_STRING = "#{DEFAULT_INTERPOLATION_SENTINEL}"
  # rubocop:enable Style/RedundantInterpolation

  attr_reader :interpolation_template_string,
              :interpolation_sentinel

  # @param [String] interpolation_template_string The template String to be used
  #   for interpolation.
  # @param [String] interpolation_sentinel The sentinel value for indicating
  #   where interpolation should happen within the
  #   {#interpolation_template_string} String.
  #
  # @raise [ArgumentError] if {#interpolation_template_string} doesn't include
  #   {#interpolation_sentinel}.
  #
  # @return [Say::InterpolationTemplate] The newly created
  #   Say::InterpolationTemplate object.
  def initialize(
        interpolation_template_string = DEFAULT_INTERPOLATION_TEMPLATE_STRING,
        interpolation_sentinel: DEFAULT_INTERPOLATION_SENTINEL)
    @interpolation_sentinel = String(interpolation_sentinel).freeze

    interpolation_template_string = String(interpolation_template_string)
    unless interpolation_template_string.include?(@interpolation_sentinel)
      raise(
        ArgumentError,
        "interpolation_template_string "\
        "(#{interpolation_template_string.inspect}) doesn't "\
        "include interpolation_sentinel: `#{@interpolation_sentinel}`")
    end

    @interpolation_template_string = interpolation_template_string.freeze
  end

  # Interpolates the given `text` into the {#interpolation_template_string}
  # String.
  #
  # @return [String]
  #
  # @example Using the Default #interpolation_template_string (`"{}="`)
  #   Say::InterpolationTemplate.new.interpolate("TEST")  # => "TEST="
  def interpolate(text)
    message = interpolation_template_string.dup
    message[interpolation_index_range] = String(text)
    message
  end

  # Calculates the length of the "decoration" portion of the
  # {#interpolation_template_string} String. This can be used to determine how
  # many columns all but the actual to-be-interpolated text/message will take
  # up.
  #
  # @return [Integer] The length of the decoration String.
  def decoration_length
    [0, interpolation_template_string.size - interpolation_sentinel_length].max
  end

  # Splits the {#interpolation_template_string} String around the
  # {#interpolation_sentinel} (plus any white space on either side). From this,
  # we can extract e.g. the left-side and right-side fill patterns for banners.
  #
  # @return [Array] The left and right sides of the split interpolation
  #   template string. Note: Will be empty if
  #   `interpolation_template_string` == `interpolation_sentinel`.
  def split
    @split ||=
      interpolation_template_string.split(
        /\s*#{Regexp.escape(interpolation_sentinel)}\s*/)
  end

  # Returns the left side of the {#split}.
  #
  # @return [String] the left side of the {#split}, or an empty String if not
  #   split-able
  def left_side
    split.first.to_s
  end

  # Returns the right side of the {#split}.
  #
  # @return [String] the right side of the {#split}, or an empty String if not
  #   split-able
  def right_side
    split.last.to_s
  end

  private

  def interpolation_index_range
    left_insertion_index..right_insertion_index
  end

  def left_insertion_index
    interpolation_template_string.index(interpolation_sentinel)
  end

  def right_insertion_index
    left_insertion_index.pred + interpolation_sentinel_length
  end

  def interpolation_sentinel_length
    interpolation_sentinel.size
  end

  # rubocop:disable all
  # :nocov:

  # Usage: Say::InterpolationTemplate.test;
  # @!visibility private
  def self.test
    Say.("Say::InterpolationTemplate.test") do
      interpolation_template_strings = [
        "{}",
        "{}=",
        "( •_•)O*¯`·.{}.·´¯`°Q(•_• )",
        "╰(⇀︿⇀)つ-]═{}-"
      ]

      results =
        interpolation_template_strings.map { |interpolation_template_string|
          obj = new(interpolation_template_string)

          {
            interpolation_template_string: obj.interpolation_template_string,
            decoration_length: obj.decoration_length,
            left_side: obj.left_side,
            right_side: obj.right_side,
            result: obj.interpolate("TEST"),
            result_for_nil: obj.interpolate(nil)
          }
        }

      expected_results = [
        {
          interpolation_template_string:  "{}",
          decoration_length:              0,
          left_side:                      "",
          right_side:                     "",
          result:                         "TEST",
          result_for_nil:                 ""
        },
        {
          interpolation_template_string:  "{}=",
          decoration_length:              1,
          left_side:                      "",
          right_side:                     "=",
          result:                         "TEST=",
          result_for_nil:                 "="
        },
        {
          interpolation_template_string:  "( •_•)O*¯`·.{}.·´¯`°Q(•_• )",
          decoration_length:              25,
          left_side:                      "( •_•)O*¯`·.",
          right_side:                     ".·´¯`°Q(•_• )",
          result:                         "( •_•)O*¯`·.TEST.·´¯`°Q(•_• )",
          result_for_nil:                 "( •_•)O*¯`·..·´¯`°Q(•_• )"
        },
        {
          interpolation_template_string:  "╰(⇀︿⇀)つ-]═{}-",
          decoration_length:              11,
          left_side:                      "╰(⇀︿⇀)つ-]═",
          right_side:                     "-",
          result:                         "╰(⇀︿⇀)つ-]═TEST-",
          result_for_nil:                 "╰(⇀︿⇀)つ-]═-"
        }
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
