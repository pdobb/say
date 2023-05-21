# frozen_string_literal: true

require_relative "say/version"
require "benchmark"

# Say is the top-level module for this gem. It utilizes `module_function` to
# allow for module-level method calls or inclusion into a class with
# instance-level methods access.
#
# @example Inclusion and instance-level methods access
#   require "say"
#
#   class IncludeProcessor
#     include Say
#
#     def run
#       say("IncludeProcessor...") {
#         say("Successfully did the thing!")
#         say("Debug details about this ...", :debug)
#         say("Info about stuff ...", :info)
#         say("Maybe look into this thing ...", :warn)
#         say("Maybe look into the above thing ...", :warning)
#         say("Failed to do a thing ...", :error)
#
#         "The Result!"
#       }
#     end
#   end
#
#   result = IncludeProcessor.new.run
#   = IncludeProcessor... ==========================================================
#    -> Successfully did the thing!
#    >> Debug details about this ...
#    -- Info about stuff ...
#    !¡ Maybe look into this thing ...
#    !¡ Maybe look into the above thing ...
#    ** Failed to do a thing ...
#   = Done =========================================================================
#
#   puts("Result: #{result.inspect}")
#   Result: "The Result!"
#
# @example Module-level access
#   require "say"
#
#   class ModuleFunctionProcessor
#     def run
#       Say.say("ModuleFunctionProcessor...") {
#         Say.say("Successfully did the thing!")
#         Say.say("Failed to do a thing ...", :error)
#
#         "The Result!"
#       }
#     end
#   end
#
#   result = ModuleFunctionProcessor.new.run
#   = ModuleFunctionProcessor... ===================================================
#    -> Successfully did the thing!
#    ** Failed to do a thing ...
#   = Done =========================================================================
#
#   puts("Result: #{result.inspect}")
#   Result: "The Result!"
module Say
  # The maximum number of columns for a built message or banner.
  #
  # @constant MAX_COLUMNS [Integer] The maximum number of columns represented as
  #   the number of characters.
  # @!scope constant
  #
  # @example
  #   MAX_COLUMNS  # => 80
  MAX_COLUMNS = 80

  # Mapping of message types to their corresponding prefixes for the `say`
  # method. Defaults to `:success`.
  #
  # @constant TYPES [Hash] A hash containing the mapping of message types to
  #   their corresponding prefixes.
  # @!scope constant
  #
  # @example
  #   TYPES[:debug]    # => " >> "
  #   TYPES[:error]    # => " ** "
  #   TYPES[:info]     # => " -- "
  #   TYPES[:success]  # => " -> "
  #   TYPES[:warn]     # => " !¡ "
  #   TYPES[:warning]  # => " !¡ "
  TYPES = {}.tap { |hash|
    hash.default = " -> "
    hash.update(
      debug: " >> ",
      error: " ** ",
      info: " -- ",
      success: hash.default,
      warn: " !¡ ")
    hash.update(warning: hash[:warn])
  }.freeze

  module_function

  # Prints a message, optionally specifying a type or executing a block of code.
  #
  # @param message [String] The message to be printed.
  # @param type [Symbol] (optional) The type of the message. (see #Say::TYPES)
  # @param block [Proc] (optional) A block of code to be executed with header
  #   and footer banners.
  #
  # @return [Object] Returns the result of the executed block if a block is
  #   given.
  # @return [String] Returns the built message if no block is given.
  def say(message, type = nil, &block)
    if block
      say_with_block(message, &block)
    else
      say_item(message, type: type)
    end
  end

  # Executes a block of code, surrounding it with header and footer messages.
  #
  # @param header_message [String] The message to be printed as the header.
  # @param footer_message [String] (optional) The message to be printed as the
  #   footer. Default is "Done".
  #
  # @yield [] The block of code to be executed.
  #
  # @return [Object] Returns the result of the executed block.
  #
  # @raise [ArgumentError] Raises an ArgumentError if no block is given.
  def say_with_block(header_message, footer_message: "Done", &block)
    raise ArgumentError, "block expected" unless block_given?

    say_header(header_message)
    result, footer_message = benchmark_block_run(footer_message, &block)
    say_footer(footer_message)

    result
  end

  private_class_method def benchmark_block_run(footer_message, &block)
    result = nil
    time = Benchmark.measure { result = block.call }
    time_string = "%.4fs" % time.real
    [result, "#{footer_message} (#{time_string})"]
  end

  # Prints a header banner (i.e. banner) that fills at least the passed in
  # `columns` number of columns. This serves as, e.g., a visual break
  # point at the end of a processing task.
  #
  # @param message [String] The message to be printed as the header.
  # @param kwargs [Hash] Additional keyword arguments to be passed to the
  #   `build_banner` method of the same class/module.
  # @option kwargs [Symbol] :columns The maximum *preferred* column length of
  #   the header message.
  #
  # @return [String] Returns the built banner message.
  #
  # @example Default (though non-standard) usage
  #   Say.say_header
  #   ================================================================================
  #   # => "================================================================================"
  #
  # @example Custom (standard) usage
  #   Say.say_header("Head")
  #   = Head =========================================================================
  #   # => "= Head ========================================================================="
  #
  #   Say.say_header("Head", columns: 20)
  #   = Head =============
  #   # => "= Head ============="
  def say_header(message = nil, **kwargs)
    do_say(build_banner(message, **kwargs))
  end

  # Prints a built message as a line using the `do_say` method.
  #
  # @param message [String] The message to be printed.
  # @param kwargs [Hash] Additional keyword arguments to be passed to the
  #   `build_message` method of the same class/module.
  #
  # @return [String] Returns the built message.
  def say_item(message, **kwargs)
    do_say(build_message(message, **kwargs))
  end

  # Prints a footer banner (i.e. banner) that fills at least the passed in
  # `columns` number of columns. This serves as, e.g., a visual break
  # point at the end of a processing task.
  #
  # @param message [String] The message to be printed as the footer.
  # @param kwargs [Hash] Additional keyword arguments to be passed to the
  #   `build_banner` method of the same class/module.
  # @option kwargs [Symbol] :columns The maximum *preferred* column length of
  #   the footer message.
  #
  # @return [String] Returns the built banner message.
  #
  # @example Default usage
  #   Say.say_footer
  #   = Done =========================================================================
  #
  #   # => "= Done =========================================================================\n\n"
  #
  # @example Custom usage
  #   Say.say_footer("Foot")
  #   = Foot =========================================================================
  #
  #   # => "= Foot =========================================================================\n\n"
  #
  #   Say.say_footer("Foot", columns: 20)
  #   = Foot =============
  #
  #   # => "= Foot =============\n\n"
  def say_footer(message = "Done", **kwargs)
    do_say(
      build_banner(message, **kwargs),
      "\n")
  end

  # Builds an banner String with the specified message.
  #
  # @param message [String] The message to be included in the banner.
  # @param columns [Integer] The maximum length of the banner line.
  #   Default value is the constant `MAX_COLUMNS`.
  #
  # @return [String] Returns the formatted banner String.
  #
  # @example Default usage
  #   Say.build_banner
  #   # => "================================================================================"
  #
  # @example Custom usage
  #   Say.build_banner("Test")
  #   # => "= Test ========================================================================="
  #
  #   Say.build_banner("Test", columns: 20)
  #   # => "= Test ============="
  def build_banner(message = nil, columns: MAX_COLUMNS)
    full_width_banner = "=" * columns
    return full_width_banner unless message

    decorations_width = 4 # Accounts for `= ` in front and ` =` at the end.
    minimum_width = message.size + decorations_width
    actual_width = [columns, minimum_width].max

    "= #{message} #{full_width_banner}"[0, actual_width]
  end

  # Builds a message with a given (or defaulted) type prefix.
  #
  # @param message [String] The message
  # @param type [Symbol] (optional) One of Say::TYPES
  #
  # @return [String] Returns the built message String.
  #
  # @example Default usage
  #   Say.build_message("Test")
  #   # => " -> Test"
  #
  # @example Custom usage
  #   Say.build_message("Test", type: :debug)
  #   # => " >> Test"
  #
  #   Say.build_message("Test", type: :error)
  #   # => " ** Test"
  #
  #   Say.build_message("Test", type: :info)
  #   # => " -- Test"
  #
  #   Say.build_message("Test", type: :success)
  #   # => " -> Test"
  #
  #   Say.build_message("Test", type: :warn)
  #   # => " !¡ Test"
  #
  #   Say.build_message("Test", type: :warning)
  #   # => " !¡ Test"
  def build_message(message, type: nil)
    "#{TYPES[type]}#{message}"
  end

  # Prints messages to the console and returns them as a single,
  # new-line-separated String.
  #
  # @param messages [Array<String>] The messages to be printed.
  # @param silent [Boolean] (optional) Controls whether the messages should be
  #   printed or not. If set to `true`, the messages will not be printed.
  #   Default is `false`.
  #
  # @return [String] Returns the messages joined by newline characters.
  def do_say(*messages, silent: false)
    puts(*messages) unless silent
    messages.join("\n")
  end
end
