# frozen_string_literal: true

# Say::Time assists with outputting Timestamps.
module Say::Time
  # The default {.timestamp} format name, if none is provided.
  DEFAULT_TIMESTAMP_FORMAT_NAME = :web_service
  private_constant :DEFAULT_TIMESTAMP_FORMAT_NAME

  # Predefined DateTime format names and values. Referenced by {.timestamp}.
  DATETIME_FORMATS = {
    long: "%m/%d/%Y %H:%M:%S %Z",                    # 06/03/2023 01:51:23 CDT
    DEFAULT_TIMESTAMP_FORMAT_NAME => "%Y%m%d%H%M%S", # 20230603014511
  }.freeze
  private_constant :DATETIME_FORMATS

  # :nocov:
  # @!visibility private

  def self.test_sample
    Time.new(1234, 5, 6, 12, 34, 56)
  end

  # :nocov:

  # Generates a formatted timestamp string based on the provided time and
  # format. If no time is specified, the current time is used. The format can be
  # specified as a symbol representing a predefined format (defined in
  # {DATETIME_FORMATS}) or as a custom format string.
  #
  # @param time [Time] The time object to generate the timestamp from.
  # @param format [Symbol, String] The format of the timestamp.
  #   If a symbol is provided, it should represent a predefined format name.
  #   If a string is provided, it should be a custom format string.
  #
  # @return [String] The formatted timestamp string.
  #
  # @example
  #   Say::Time.timestamp                         # => "20230603015445"
  #   Say::Time.timestamp(format: :web_service))  # => "20230603015445"
  #   Say::Time.timestamp(format: :long)          # => "06/03/2023 01:51:23 CDT"
  #   Say::Time.timestamp(format: "%H:%M:%S")     # => "01:51:23"
  def self.timestamp(time = Time.now, format: DEFAULT_TIMESTAMP_FORMAT_NAME)
    format_string =
      if format.is_a?(Symbol)
        DATETIME_FORMATS.fetch(format)
      else
        String(format)
      end

    time.strftime(format_string)
  end
end
