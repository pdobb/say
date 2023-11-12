# frozen_string_literal: true

# Say::Banner is a generator for (justified) banner Strings.
module Say::BannerGenerator
  def self.call(text, columns:, justify:)
    interpolation_template = build_interpolation_template(text)
    interpolation_template.public_send(
      "#{justify}_justify", text, length: columns)
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
    text ? :title : :hr
  end
  private_class_method :determine_banner_type
end
