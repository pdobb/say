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

  # Prints either a one-line message of the given type or executes a block of
  # code and surrounds it with header and footer banner messages.
  #
  # @param text [String] (optional) The message to be printed.
  # @param type [Symbol] (optional) The type of the message. (see #Say::TYPES)
  # @param block [Proc] (optional) A block of code to be executed with header
  #   and footer banners.
  #
  # @return [Object] Returns the result of the executed block if a block is
  #   given.
  # @return [String] Returns the built message if no block is given.
  #
  # @example No Block Given
  #   Say.say("Hello, World!")  # => " -> Hello, World!"
  #   Say.say("Oops", :error)   # => " ** Oops"
  #   Say.say                   # => " ..."
  #
  # @example Given a Block
  #   Say.say("Hello, World!") {
  #     Say.say("Huzzah!")
  #     Say.say("Hmm...", :info)
  #     "My Result!"
  #   }
  #   = Hello, World! ================================================================
  #    -> Huzzah!
  #    -- Hmm...
  #   = Done (0.0000s) ===============================================================
  #
  #   # => "My Result!"
  def say(text = nil, type = nil, &block)
    if block
      say_with_block(header: text, &block)
    else
      say_result(text, type: type)
    end
  end

  # Executes a block of code, surrounding it with header and footer banner
  # messages.
  #
  # @param header [String] The message to be printed in the header.
  # @param footer [String] (optional) The message to be printed in the footer.
  #   Default is "Done".
  #
  # @yield [] The block of code to be executed.
  #
  # @return [Object] Returns the result of the executed block.
  #
  # @raise [ArgumentError] Raises an ArgumentError if no block is given.
  #
  # @example
  #   Say.say_with_block("Hello, World!") {
  #     Say.say("Huzzah!")
  #     Say.say("Hmm...", :info)
  #     "My Result!"
  #   }
  #   = Hello, World! ================================================================
  #    -> Huzzah!
  #    -- Hmm...
  #   = Done (0.0000s) ===============================================================
  #
  #   # => "My Result!"
  def say_with_block(header: nil, footer: "Done", &block)
    raise ArgumentError, "block expected" unless block_given?

    say_header(header)
    result, footer_with_time_string = benchmark_block_run(footer, &block)
    say_footer(footer_with_time_string)

    result
  end

  private_class_method def benchmark_block_run(message, &block)
    result = nil
    time = Benchmark.measure { result = block.call }
    time_string = "%.4fs" % time.real
    [result, "#{message} (#{time_string})"]
  end

  # Prints a header banner (i.e. banner) that fills at least the passed in
  # `columns` number of columns. This serves as, e.g., a visual break
  # point at the end of a processing task.
  #
  # @param text [String] (optional) The message to be printed as the header.
  # @param kwargs [Hash] Additional keyword arguments to be passed to the
  #   `say_banner` method of the same class/module.
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
  def say_header(text = nil, **kwargs)
    do_say(say_banner(text, **kwargs))
  end

  # Prints a a one-line message of the given type.
  #
  # @param text [String] (optional) The message to be printed.
  # @param kwargs [Hash] Additional keyword arguments to be passed to the
  #   `say_message` method of the same class/module.
  #
  # @return [String] Returns the built message.
  #
  # @example
  #   Say.say_result("Hello, World!")  # => " -> Hello, World!"
  #   Say.say_result("Oops", :error)   # => " ** Oops"
  #   Say.say_result                   # => " ..."
  def say_result(text = nil, **kwargs)
    do_say(say_message(text, **kwargs))
  end

  # Prints a footer banner (i.e. banner) that fills at least the passed in
  # `columns` number of columns. This serves as, e.g., a visual break
  # point at the end of a processing task.
  #
  # @param text [String] The message to be printed as the footer.
  # @param kwargs [Hash] Additional keyword arguments to be passed to the
  #   `say_banner` method of the same class/module.
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
  def say_footer(text = "Done", **kwargs)
    do_say(
      say_banner(text, **kwargs),
      "\n")
  end

  # Builds an banner String with the specified message.
  #
  # @param text [String] (optional) The message to be included in the banner.
  # @param columns [Integer] The maximum length of the banner line.
  #   Default value is the constant `MAX_COLUMNS`.
  #
  # @return [String] Returns the formatted banner String.
  #
  # @example Default usage
  #   Say.say_banner
  #   # => "================================================================================"
  #
  # @example Custom usage
  #   Say.say_banner("Test")
  #   # => "= Test ========================================================================="
  #
  #   Say.say_banner("Test", columns: 20)
  #   # => "= Test ============="
  def say_banner(text = nil, columns: MAX_COLUMNS)
    full_width_banner = "=" * columns
    return full_width_banner unless text

    decorations_width = 4 # Accounts for `= ` in front and ` =` at the end.
    minimum_width = text.size + decorations_width
    actual_width = [columns, minimum_width].max

    "= #{text} #{full_width_banner}"[0, actual_width]
  end

  # Builds a message with a given (or defaulted) type prefix.
  #
  # @param text [String] (optional) The message. Defaults to `" ..."`.
  # @param type [Symbol] (optional) One of Say::TYPES
  #
  # @return [String] Returns the built message String.
  #
  # @example Default usage
  #   Say.say_message("Test")  # => " -> Test"
  #
  # @example Custom usage
  #   Say.say_message("Test", type: :debug)    # => " >> Test"
  #   Say.say_message("Test", type: :error)    # => " ** Test"
  #   Say.say_message("Test", type: :info)     # => " -- Test"
  #   Say.say_message("Test", type: :success)  # => " -> Test"
  #   Say.say_message("Test")                  # => " -> Test"
  #   Say.say_message("Test", type: :warn)     # => " !¡ Test"
  #   Say.say_message("Test", type: :warning)  # => " !¡ Test"
  #   Say.say_message                          # => " ..."
  def say_message(text = nil, type: nil)
    return " ..." unless text

    "#{TYPES[type]}#{text}"
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
