# frozen_string_literal: true

# Say::Banner is a generator for (justified) banner Strings.
module Say::BannerGenerator
  # Generate a justified banner String.
  #
  # @param text [String] The text to be included in the banner.
  #   If `text` is empty, the banner will be of type `:double_line`.
  #   Else the banner will be of type `:title`.
  # @param columns [Integer] The desired overall String length; may not be
  #   respected if the `text` + minimal banner elements are greater than
  #   `columns` in length.
  # @param justify [#to_s] One of %i[left center right]; Text justification vs
  #   overall banner length.
  def self.call(text, columns:, justify:)
    interpolation_template = build_interpolation_template(text)
    interpolation_template.public_send(
      :"#{justify}_justify", text, length: columns
    )
  end

  def self.build_interpolation_template(text)
    type = determine_banner_type(text)
    Say::InterpolationTemplate::Builder.(type)
  end
  private_class_method :build_interpolation_template

  # @see Say::InterpolationTemplate::Builder::TYPES
  #
  # :reek:ControlParameter
  def self.determine_banner_type(text)
    text ? :title : :double_line
  end
  private_class_method :determine_banner_type
end
