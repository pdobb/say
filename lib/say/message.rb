# frozen_string_literal: true

# Say::Message represents the user-supplied text and output type, to be
# outputted by the various Say.* methods.
#
# @example Default Output, given no text or type
#   Say::Message.new.to_s  # => " ..."
#
# @example Given no type
#   Say::Message.new("Test").to_s  # => " -> Test"
#
# @example Given a type
#   Say::Message.new("Test", type: :debug).to_s    # => " >> Test"
#   Say::Message.new("Test", type: :error).to_s    # => " ** Test"
#   Say::Message.new("Test", type: :info).to_s     # => " -- Test"
#   Say::Message.new("Test", type: :success).to_s  # => " -> Test"
#   Say::Message.new("Test").to_s                  # => " -> Test"
#   Say::Message.new("Test", type: :warn).to_s     # => " !¡ Test"
#   Say::Message.new.to_s                          # => " ..."
class Say::Message
  # The default Message "TYPE" if no `type` name is provided.
  DEFAULT_TYPE = :success

  # Mapping of message types to their corresponding prefixes for the `say`
  # method. Defaults to `:success` given an unknown key.
  #
  # @example
  #   Say::Message::TYPES[:debug]    # => " >> "
  #   Say::Message::TYPES[:error]    # => " ** "
  #   Say::Message::TYPES[:info]     # => " -- "
  #   Say::Message::TYPES[:success]  # => " -> "
  #   Say::Message::TYPES[:warn]     # => " !¡ "
  TYPES = {}.tap { |hash|
    hash.default = " -> "
    hash.update(
      debug: " >> ",
      error: " ** ",
      info: " -- ",
      DEFAULT_TYPE => hash.default,
      warn: " !¡ ",
    )
  }.freeze

  # The default message to use when one is not supplied.
  DEFAULT_MESSAGE = " ..."

  attr_reader :text,
              :type

  # :reek:ControlParameter

  # @param text [String] (DEFAULT_MESSAGE) The user-supplied text.
  # @param type [Symbol] One of Say::Message::TYPES.keys
  def initialize(text = nil, type: DEFAULT_TYPE)
    @text = text
    @type = type || DEFAULT_TYPE
  end

  # Return the built message as a String.
  #
  # @return [String]
  def to_s
    return DEFAULT_MESSAGE unless text

    "#{TYPES[type]}#{text}"
  end
end
