# frozen_string_literal: true

# Say::Time assist with outputting Timestamps.
class Say::Time
  DATETIME_FORMATS = {
    long: "%m/%d/%Y %H:%M:%S %Z", # 06/03/2023 01:51:23 CDT
    web_service: "%Y%m%d%H%M%S",  # 20230603014511
  }.freeze

  DEFAULT_TIMESTAMP_FORMAT_NAME = :web_service

  def self.test_sample
    Time.new(1234, 5, 6, 12, 34, 56)
  end

  # Generates a formatted timestamp string based on the provided time and
  # format. If no time is specified, the current time is used. The format can be
  # specified as a symbol representing a predefined format (defined in
  # {DATETIME_FORMATS}) or as a custom format string.
  #
  # @param [Time] time The time object to generate the timestamp from.
  # @param [Symbol, String] format The format of the timestamp.
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
