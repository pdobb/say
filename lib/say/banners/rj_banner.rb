# frozen_string_literal: true

# Say::RJBanner builds customizable right-justified banner strings.
#
# Specify an `interpolation_template` on initialization to define the preferred
# visual style, and then call {#Say::RJBanner#call} to perform left-side
# pattern-fill (up to `columns` length) based on the passed in
# `interpolation_template`.
#
# Specifying the `interpolation_template` is aided by
# {Say::RJBanner::InterpolationTemplateBuilder}.
#
# @see Say::RJBanner::InterpolationTemplateBuilder
# @see Say::InterpolationTemplate The Default Interpolation Template Class
#
# @example Default Interpolation Template (type: `:title`)
#   Say::RJBanner.new.("My Banner")
#   # => "==================================================================== My Banner ="
#
# @example `hr` Interpolation Template (type: `:hr`)
#   Say::RJBanner.new(:hr).call
#   # => "================================================================================"
#
# @example Custom Interpolation Template
#   Say::RJBanner.new(".··.{}.·´¯`°Q(•_• )", columns: 60).("Cheerio!")
#   # => ".··..··..··..··..··..··..··..··..··.··.Cheerio!.·´¯`°Q(•_• )"
#
#   OR:
#
#   interpolation_template =
#     Say::RJBanner::InterpolationTemplateBuilder.(".··.{}.·´¯`°Q(•_• )")
#   banner = Say::RJBanner.new(interpolation_template, columns: 60)
#   banner.("Cheerio!")
#   # => ".··..··..··..··..··..··..··..··..··.··.Cheerio!.·´¯`°Q(•_• )"
class Say::RJBanner
  attr_reader :columns,
              :interpolation_template

  def initialize(type_or_template_string = nil, columns: Say::MAX_COLUMNS)
    @interpolation_template =
      Say::RJBanner::InterpolationTemplateBuilder.(type_or_template_string)
    @columns = Integer(columns)
  end

  # Right-justify and left-fill the given `text` based on the rules of the
  # {#interpolation_template}.
  def call(text = "")
    text = block_given? ? yield : String(text)
    justify(interpolation_template.interpolate(text))
  end

  private

  # @param interpolated_text [String] e.g.: `= TEST =` -- Here, we just need to
  #   fill in the left side of the passed in `interpolated_text` String with
  #   the interpolation_template fill pattern.
  def justify(interpolated_text = "")
    it_filler =
      InterpolationTemplateFiller.new(
        banner: self,
        interpolated_text: interpolated_text)
    it_filler.call
  end

  # Say::RJBanner::InterpolationTemplateFiller is an "Interpolation Template
  # Filler" that is specific to the needs of the Say::LJBaner object. It appeals
  # to {Say::InterpolationTemplate#left_side} to determine the "fill pattern"
  # (found on the left side of the interpolation sentinel) and will then
  # right-justify the given {#interpolated_text} by repeating the fill pattern
  # onto the beginning, up to {Say::RJBanner#columns} total characters.
  class InterpolationTemplateFiller
    attr_reader :banner,
                :interpolated_text

    # @param banner [Say::RJBanner]
    # @param interpolated_text [String] The text String after interpolation has
    #   occurred, but before the filler pattern has been applied.
    #   e.g.: `= TEST =` (which will then become `"=[...]====== TEST ")
    def initialize(banner:, interpolated_text:)
      @banner = banner
      @interpolated_text = interpolated_text
    end

    # If there is a non-empty fill pattern:
    #   Right-justify the given {#interpolated_text} by repeating the fill
    #   pattern onto the end, up to {#target_length} total characters.
    # Else:
    #   Return {#interpolated_text} directly. (Because otherwise `rjust`
    #   raises an ArgumentError.)
    def call
      return interpolated_text unless fill_pattern?

      interpolated_text.rjust(target_length, fill_pattern) # 👀
    end

    private

    def target_length
      [columns, interpolated_text.size].max
    end

    def columns
      banner.columns
    end

    def interpolation_template
      banner.interpolation_template
    end

    # Extracts the fill pattern from the {#interpolation_template}.
    #
    # The fill pattern for Say::RJBanner, specifically, is the left part of the
    # {Say::InterpolationTemplate#interpolation_template_string} String.
    #
    # @return [String] The fill pattern, extracted from the interpolation
    #   template.
    def fill_pattern
      interpolation_template.left_side # 👀
    end

    # Checks if a fill pattern exists in the {#interpolation_template_string}
    # String.
    #
    # @return [Boolean] Returns true if a fill pattern exists; otherwise, false.
    def fill_pattern?
      fill_pattern != ""
    end
  end

  # Say::RJBanner::InterpolationTemplateBuilder is a factory for creating
  # Interpolation Template objects from the optionally given type or
  # interpolation template String.
  #
  # If a type is given to the {.call} method, it passes through directly.
  # Else, if a Symbol or String is given, it is converted into the appropriate
  # InterpolationTemplate type (class) by referencing the
  # {Say::RJBanner::InterpolationTemplateBuilder::TYPES} hash.
  #
  # The default Interpolation Template class is {Say::InterpolationTemplate}.
  module InterpolationTemplateBuilder
    DEFAULT_INTERPOLATION_TEMPLATE_CLASS = Say::InterpolationTemplate
    INTERPOLATION_SENTINEL =
      Say::InterpolationTemplate::DEFAULT_INTERPOLATION_SENTINEL

    DEFAULT_TYPE = :title
    TYPES = {
      hr: "=#{INTERPOLATION_SENTINEL}", # 👀
      DEFAULT_TYPE => "= #{INTERPOLATION_SENTINEL} =",
      wtf: "? #{INTERPOLATION_SENTINEL} ?",
    }.freeze

    # rubocop:disable Style/CommentedKeyword
    # rubocop:disable Layout/LineLength
    TYPES.each_key do |name|
      define_singleton_method(name) do                # def self.<name>
        call(to_interpolation_template_string(name))  #   call(to_interpolation_template_string(<name>))
      end                                             # end
    end
    # rubocop:enable Layout/LineLength
    # rubocop:enable Style/CommentedKeyword

    # @param type_or_template_string [#to_sym] one of `TYPES.keys`.
    def self.to_interpolation_template_string(type_or_template_string)
      case type_or_template_string
      when Symbol
        TYPES.fetch(type_or_template_string)
      else
        String(type_or_template_string)
      end
    end

    def self.call(
          type_or_template_string = nil,
          interpolation_template_class: DEFAULT_INTERPOLATION_TEMPLATE_CLASS)
      if type_or_template_string.is_a?(interpolation_template_class)
        return type_or_template_string
      end

      interpolation_template_string =
        to_interpolation_template_string(
          type_or_template_string || DEFAULT_TYPE)
      interpolation_template_class.new(interpolation_template_string)
    end
  end

  # rubocop:disable all
  # :nocov:

  # Usage: Say::RJBanner.test;
  # @!visibility private
  def self.test
    Say.("Say::RJBanner.test") do
      itb = Say::RJBanner::InterpolationTemplateBuilder
      results = [
        new.("DEFAULT"),
        new(itb.title, columns: 0).("TITLE + MIN LENGTH"),
        new(itb.("~= {} ~=")).("CUSTOM"),
        new(itb.("^.^  {}  ^.^"), columns: 40).("CUSTOM + SHORT"),
        new(itb.("( •_•)O*¯`·.{}.·´¯`°Q(•_• )")).("." * 30), # Begs for Left/Right Split Justification...
        new(itb.hr).call,
        new(itb.(:hr)).("HR"),
        new(itb.wtf).() {
          new(itb.(:unknown)).("UNKNOWN TEMPLATE TYPE") rescue "CAUGHT: #{$!.message}"
        },
      ]

      expected_results = [
        "====================================================================== DEFAULT =",
        "= TITLE + MIN LENGTH =",
        "~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~= CUSTOM ~=",
        "^.^^.^^.^^.^^.^^^.^  CUSTOM + SHORT  ^.^",
        "( •_•)O*¯`·.( •_•)O*¯`·.(( •_•)O*¯`·................................·´¯`°Q(•_• )",
        "================================================================================",
        "==============================================================================HR",
        "?????????????????????????????????????????????? CAUGHT: key not found: :unknown ?",
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
