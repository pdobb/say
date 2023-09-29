# frozen_string_literal: true

# Say::LJBanner builds customizable left-justified banner strings.
#
# Specify an `interpolation_template` on initialization to define the preferred
# visual style, and then call {#Say::LJBanner#call} to perform right-side
# pattern-fill (up to `columns` length) based on the passed in
# `interpolation_template`.
#
# Specifying the `interpolation_template` is aided by
# {Say::LJBanner::ITBuilder}.
#
# @see Say::LJBanner::ITBuilder
# @see Say::InterpolationTemplate The Default Interpolation Template Class
#
# @example Default Interpolation Template (`title`)
#   Say::LJBanner.new.("My Banner")
#   # => "= My Banner ===================================================================="
#
# @example The `hr` Interpolation Template
#   interpolation_template = Say::LJBanner::ITBuilder.hr
#   banner = Say::LJBanner.new(interpolation_template)
#   banner.call
#   # => "================================================================================"
#
# @example Custom Interpolation Template
#   interpolation_template = Say::LJBanner::ITBuilder("╰(⇀︿⇀)つ-]═----{}-")
#   banner = Say::LJBanner.new(interpolation_template, columns: 60)
#   banner.("¡EN GARDE!")
#   # => "╰(⇀︿⇀)つ-]═----¡EN GARDE!------------------------------------"
class Say::LJBanner
  attr_reader :columns,
              :interpolation_template

  def initialize(type_or_template_string = nil, columns: Say::MAX_COLUMNS)
    @interpolation_template = ITBuilder.(type_or_template_string)
    @columns = Integer(columns)
  end

  # Left-justify and right-fill the given `text` based on the rules of the
  # {#interpolation_template}.
  def call(text = "")
    text = block_given? ? yield : String(text)
    left_justify(interpolation_template.interpolate(text))
  end

  private

  # @param interpolated_text [String] e.g.: `= TEST =` -- Here, we just need to
  #   fill in the right side of the passed in `interpolated_text` String with
  #   the interpolation_template fill pattern.
  def left_justify(interpolated_text = "")
    it_filler = ITFiller.new(banner: self, interpolated_text: interpolated_text)
    it_filler.call
  end

  # Say::LJBanner::ITFiller is an Interpolation Template Filler specific to the
  # Say::LJBaner object. It appeals to {Say::InterpolationTemplate#right_side}
  # to determine the "fill pattern" and will then left-justify the given
  # {#interpolated_text} by repeating the fill pattern onto the end, up to
  # {Say::LJBanner#columns} in length.
  class ITFiller
    attr_reader :banner,
                :interpolated_text

    def initialize(banner:, interpolated_text:)
      @banner = banner
      @interpolated_text = interpolated_text
    end

    def call
      if fill_pattern?
        interpolated_text.ljust(target_length, fill_pattern)
      else
        interpolated_text
      end
    end

    private

    def target_length
      [
        columns,
        interpolated_text.size - interpolation_template.decoration_length,
      ].max
    end

    # Extracts the fill pattern from the {#interpolation_template}.
    #
    # The fill pattern for Say::LJBanner, specifically, is the right part of the
    # {Say::InterpolationTemplate#interpolation_template_string} String.
    #
    # @return [String] The fill pattern, extracted from the interpolation
    #   template.
    def fill_pattern
      interpolation_template.right_side
    end

    # Checks if a fill pattern exists in the {#interpolation_template_string}
    # String.
    #
    # @return [Boolean] Returns true if a fill pattern exists; otherwise, false.
    def fill_pattern?
      fill_pattern != ""
    end

    def interpolation_template
      banner.interpolation_template
    end

    def columns
      banner.columns
    end
  end

  # Say::LJBanner::ITBuilder is a factory for creating Interpolation Template
  # objects from the optionally given interpolation template String. The default
  # Interpolation Template class is {Say::InterpolationTemplate}.
  module ITBuilder
    DEFAULT_INTERPOLATION_TEMPLATE_CLASS = Say::InterpolationTemplate
    INTERPOLATION_SENTINEL =
      Say::InterpolationTemplate::DEFAULT_INTERPOLATION_SENTINEL

    TYPES = {
      hr: "#{INTERPOLATION_SENTINEL}=",
      title: "= #{INTERPOLATION_SENTINEL} =",
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
        to_interpolation_template_string(type_or_template_string || :title)
      interpolation_template_class.new(interpolation_template_string)
    end
  end

  # rubocop:disable all
  # :nocov:

  # Usage: Say::LJBanner.test;
  # @!visibility private
  def self.test
    Say.("Say::LJBanner.test") do
      results = [
        new.("DEFAULT"),
        new(ITBuilder.title, columns: 20).("TITLE + SHORT"),
        new(ITBuilder.("~= {} ~=")).("CUSTOM"),
        new(ITBuilder.("^.^  {}  ^.^"), columns: 40).("CUSTOM + SHORT"),
        new(ITBuilder.("( •_•)O*¯`·.{}.·´¯`°Q(•_• )")).("." * 30), # Begs for Left/Right Split Justification...
        new(ITBuilder.("╰(⇀︿⇀)つ-]═----{}-")).("¡EN GARDE!"),
        new(ITBuilder.hr).call,
        new(ITBuilder.(:hr)).("HR"),
        new(ITBuilder.wtf).() {
          (new(ITBuilder.(:unknown)).("UNKNOWN TEMPLATE TYPE") rescue "CAUGHT: #{$!.message}")
        },
      ]

      expected_results = [
        "= DEFAULT ======================================================================",
        "= TITLE + SHORT ====",
        "~= CUSTOM ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=",
        "^.^  CUSTOM + SHORT  ^.^^.^^.^^.^^.^^.^^",
        "( •_•)O*¯`·................................·´¯`°Q(•_• ).·´¯`°Q(•_• ).·´¯`°Q(•_• ",
        "╰(⇀︿⇀)つ-]═----¡EN GARDE!--------------------------------------------------------",
        "================================================================================",
        "HR==============================================================================",
        "? CAUGHT: key not found: :unknown ??????????????????????????????????????????????"
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
