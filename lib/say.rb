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
#       say("IncludeProcessor") {
#         say("Successfully did the thing!")
#         say
#         say("Debug details about this ...", :debug)
#         say("Info about stuff ...", :info)
#         say("Maybe look into this thing ...", :warn)
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
#   result  # => "The Result!"
#
# @example Direct access via `Say.<method>`
#   require "say"
#
#   class DirectAccessProcessor
#     def run
#       Say.("DirectAccessProcessor") {
#         Say.("Successfully did the thing!")
#         Say.() # Or: Say.call
#         Say.("Debug details about this ...", :debug)
#         Say.("Info about stuff ...", :info)
#         Say.("Maybe look into this thing ...", :warn)
#         Say.("Failed to do a thing ...", :error)
#
#         "The Result!"
#       }
#     end
#   end
#
#   result = DirectAccessProcessor.new.run
#   = DirectAccessProcessor ========================================================
#    -> Successfully did the thing!
#    ...
#    >> Debug details about this ...
#    -- Info about stuff ...
#    !¡ Maybe look into this thing ...
#    !¡ Maybe look into the above thing ...
#    ** Failed to do a thing ...
#   = Done (0.0000s) ===============================================================
#
#   result  # => "The Result!"
module Say
  # The maximum number of columns for message types that support it, e.g.
  # banners.
  MAX_COLUMNS = 80

  # Mapping of message types to their corresponding prefixes for the `say`
  # method. Defaults to `:success`.
  #
  # @example
  #   TYPES[:debug]    # => " >> "
  #   TYPES[:error]    # => " ** "
  #   TYPES[:info]     # => " -- "
  #   TYPES[:success]  # => " -> "
  #   TYPES[:warn]     # => " !¡ "
  TYPES = {}.tap { |hash|
    hash.default = " -> "
    hash.update(
      debug: " >> ",
      error: " ** ",
      info: " -- ",
      success: hash.default,
      warn: " !¡ ")
  }.freeze

  # The default message to print when one is not supplied.
  DEFAULT_MESSAGE = " ..."

  DONE_MESSAGE = "Done"
  START_MESSAGE = "Start"

  # Prints either a one-line message of the given type or executes a block of
  # code and surrounds it with header and footer banner messages.
  #
  # @param text [String] (optional) The message to be printed.
  # @param type [Symbol] (optional) The type of the message. (see #Say::TYPES)
  #   Note: `type` is ignored if a block is given.
  # @param block [Proc] (optional) A block of code to be called with header and
  #   footer banners.
  #
  # @return [] Returns the result of the called block if a block is given.
  # @return [String] Returns the built message if no block is given.
  #
  # @example No Block Given
  #   Say.("Hello, World!")  # => " -> Hello, World!"
  #   Say.("Oops", :error)   # => " ** Oops"
  #   Say.()                 # => " ..."
  #
  # @example Given a Block
  #   Say.("Hello, World!") {
  #     Say.("Huzzah!")
  #     Say.("Hmm...", :info)
  #     "My Result!"
  #   }
  #   = Hello, World! ================================================================
  #    -> Huzzah!
  #    -- Hmm...
  #   = Done (0.0000s) ===============================================================
  #
  #   # => "My Result!"
  def self.call(text = nil, type = nil, &block)
    if block
      with_block(header: text, &block)
    else
      line(text, type: type)
    end
  end

  # Prints a built one-line message of the given type using {Say.write}.
  #
  # @param text [String] (optional) The message to be printed.
  # @param kwargs [Hash] Additional keyword arguments to be passed to the
  #   `message` method of the same class/module.
  #
  # @return [String] Returns the built message.
  #
  # @example
  #   Say.line("Hello, World!")  # => " -> Hello, World!"
  #   Say.line("Oops", :error)   # => " ** Oops"
  #   Say.line                   # => " ..."
  def self.line(text = nil, **kwargs)
    write(build_message(text, **kwargs))
  end

  # Executes a block of code, surrounding it with header and footer banner
  # messages.
  #
  # @param header [String] The message to be printed in the header.
  # @param footer [String] (optional) The message to be printed in the footer.
  #   Default is {Say::DONE_MESSAGE}.
  #
  # @yield [] The block of code to be called.
  #
  # @return [] Returns the result of the called block.
  #
  # @raise [ArgumentError] Raises an ArgumentError if no block is given.
  #
  # @example
  #   Say.with_block("Hello, World!") {
  #     Say.("Huzzah!")
  #     Say.("Hmm...", :info)
  #     "My Result!"
  #   }
  #   = Hello, World! ================================================================
  #    -> Huzzah!
  #    -- Hmm...
  #   = Done (0.0000s) ===============================================================
  #
  #   # => "My Result!"
  def self.with_block(header: nil, footer: DONE_MESSAGE, &block)
    raise ArgumentError, "block expected" unless block

    self.header(header)
    result, footer_with_runtime_string = benchmark_block_run(footer, &block)
    self.footer(footer_with_runtime_string)

    result
  end

  def self.benchmark_block_run(message, &block)
    result = nil
    time = Benchmark.measure { result = block.call }
    time_string = "%.4fs" % time.real
    [result, "#{message} (#{time_string})"]
  end
  private_class_method :benchmark_block_run

  # Prints a header banner (using {Say.write}) that fills at least the passed in
  # `columns` number of columns. This serves as, e.g., a visual break point at
  # the start of a processing task.
  #
  # @param text [String] (optional) The message to be printed as the header.
  # @param kwargs [Hash] Additional keyword arguments to be passed to the
  #   `banner` method of the same class/module.
  # @option kwargs [Symbol] :columns The maximum *preferred* column length of
  #   the header message.
  #
  # @return [String] Returns the built banner message.
  #
  # @example Default (though non-standard) usage
  #   Say.header
  #   ================================================================================
  #   # => "================================================================================"
  #
  # @example Custom (standard) usage
  #   Say.header("Head")
  #   = Head =========================================================================
  #   # => "= Head ========================================================================="
  #
  #   Say.header("Head", columns: 20)
  #   = Head =============
  #   # => "= Head ============="
  def self.header(text = nil, **kwargs)
    banner(text, **kwargs)
  end

  # Prints a footer banner (using {Say.write}) that fills at least the passed in
  # `columns` number of columns. This serves as, e.g., a visual break
  # point at the end of a processing task.
  #
  # @param text [String] The message to be printed as the footer.
  # @param kwargs [Hash] Additional keyword arguments to be passed to the
  #   `banner` method of the same class/module.
  # @option kwargs [Symbol] :columns The maximum *preferred* column length of
  #   the footer message.
  #
  # @return [String] Returns the built banner message.
  #
  # @example Default usage
  #   Say.footer
  #   = Done =========================================================================
  #
  #   # => "= Done =========================================================================\n\n"
  #
  # @example Custom usage
  #   Say.footer("Foot")
  #   = Foot =========================================================================
  #
  #   # => "= Foot =========================================================================\n\n"
  #
  #   Say.footer("Foot", columns: 20)
  #   = Foot =============
  #
  #   # => "= Foot =============\n\n"
  def self.footer(text = DONE_MESSAGE, **kwargs)
    result = banner(text, **kwargs)
    write("\n")
    result
  end

  # Prints a banner String with the specified message using {Say.write}. If no
  # message is supplied, just prints a full-width banner String.
  #
  # @param text [String] (optional) The message to be included in the banner.
  # @param columns [Integer] The maximum length of the banner line.
  #   Default value is the constant `MAX_COLUMNS`.
  #
  # @return [String] Returns the formatted banner String.
  #
  # @example Default usage
  #   Say.banner
  #   # => "================================================================================"
  #
  # @example Custom usage
  #   Say.banner("Test")
  #   # => "= Test ========================================================================="
  #
  #   Say.banner("Test", columns: 20)
  #   # => "= Test ============="
  def self.banner(text = nil, columns: MAX_COLUMNS)
    type = text ? nil : :hr
    write(LJBanner.new(type, columns: columns).(text))
  end

  # Builds a message with a given (or defaulted) type prefix.
  #
  # @param text [String] (optional) The message. Defaults to `" ..."`.
  # @param type [Symbol] (optional) One of Say::TYPES
  #
  # @return [String] Returns the built message String.
  #
  # @example Default usage
  #   Say.build_message("Test")  # => " -> Test"
  #
  # @example Custom usage
  #   Say.build_message("Test", type: :debug)    # => " >> Test"
  #   Say.build_message("Test", type: :error)    # => " ** Test"
  #   Say.build_message("Test", type: :info)     # => " -- Test"
  #   Say.build_message("Test", type: :success)  # => " -> Test"
  #   Say.build_message("Test")                  # => " -> Test"
  #   Say.build_message("Test", type: :warn)     # => " !¡ Test"
  #   Say.build_message                          # => " ..."
  def self.build_message(text = nil, type: nil)
    return DEFAULT_MESSAGE unless text

    "#{TYPES[type]}#{text}"
  end
  private_class_method :build_message

  # Builds a {Say::Progress::Tracker} and yields an associated
  # {Say::Progress::Interval} the user-supplied block for printing `say`
  # messages only for on-interval ticks through the loop.
  #
  # @param message [String] The String to be printed in the header banner.
  #
  # @yield [Say::Progress::Interval] The interval upon which to `say` things.
  #
  # @return [] Returns the result of the called block.
  #
  # @example Simple Example
  #   Say.progress do |interval|
  #     3.times do
  #       interval.update
  #       interval.say("Test", :debug)
  #     end
  #   end
  #   = [20230604151646] Start (i=0) =================================================
  #   [20230604151646]  >> Test (i=1)
  #   [20230604151646]  >> Test (i=2)
  #   [20230604151646]  >> Test (i=3)
  #   = Done (0.0000s) ===============================================================
  #
  # @example A More Advanced Example
  #   Say.progress("Progress Tracking Test", interval: 2) do |interval|
  #     0.upto(2) do |index|
  #       interval.update(index)
  #       interval.say("Before Update Interval. Index: #{index}", :debug)
  #       interval.say("Progress Interval Block.") do
  #         sleep(0.025) # Do the work here...
  #         Say.("Interval-Agnostic Update. Index: #{index}", :info)
  #       end
  #       interval.say("After Update Interval. Index: #{index}", :debug)
  #     end
  #   end
  #   = [12340506123456] Progress Tracking Test (i=0) ================================
  #    -- Interval-Agnostic Update. Index: 0
  #    -- Interval-Agnostic Update. Index: 1
  #   [12340506123456]  >> Before Update Interval. Index: 2 (i=2)
  #   = [12340506123456] Progress Interval Block. (i=2) ==============================
  #    -- Interval-Agnostic Update. Index: 2
  #   = Done (0.0265s) ===============================================================
  #
  #   [12340506123456]  >> After Update Interval. Index: 2 (i=2)
  #   = Done (0.0797s) ===============================================================
  def self.progress(message = START_MESSAGE, **kwargs, &block)
    tracker = Say::Progress::Tracker.new(**kwargs)

    header = progress_message(message, index: tracker.index)

    with_block(header: header) do
      tracker.call(&block)
    end
  end

  # Prints a {#progress_message} (one that includes the original text plus an
  # indicator of the given `index`) via {Say.say}.
  #
  # @param text [String] The String to be printed, which will be appended with
  #   an indicator of the given `index`.
  # @param type [Symbol] (optional) The type of the message. (see #Say::TYPES)
  # @param index [Integer] (optional)
  #
  # @example Typical Usage
  #   Say.progress_line("TEST", index: 3)
  #   # => "[12340506123456]  -- TEST (i=3)"
  #
  #   Say.progress_line("TEST", :success, index: 3)
  #   # => "[12340506123456]  -> TEST (i=3)"
  #
  # @example Given no Index
  #   Say.progress_line("TEST", :success)
  #   # => "[12340506123456]  -> TEST"
  #
  # @example Given No Message
  #   Say.progress_line(index: 3)
  #   # => "[12340506123456]  ... (i=3)"
  def self.progress_line(text = nil, type = :info, index: nil)
    message = build_message(text, type: type)
    full_message = progress_message(message, index: index)

    write(full_message)
  end

  # @example
  #   Say.__send__(:progress_message, "TEST")
  #   # => "[12340506123456] TEST"
  #
  #   Say.__send__(:progress_message, "TEST", index: 1)
  #   # => "[12340506123456] TEST (i=1)"
  #
  #   Say.__send__(:progress_message, "TEST", index: 1, time_format: :long)
  #   # => "[05/06/1234 12:34:56 CST] TEST (i=1)"
  def self.progress_message(message, index: nil, time_format: :web_service)
    timestamp = Say::Time.timestamp(format: time_format)

    [
      "[#{timestamp}]",
      message,
      ("(i=#{index})" if index),
    ].compact.join(" ")
  end
  private_class_method :progress_message

  # Prints messages to the console and returns them as a single,
  # new-line-separated String.
  #
  # @param messages [Array<String>] The messages to be printed.
  # @param silent [Boolean] (optional) Controls whether the messages should be
  #   printed or not. If set to `true`, the messages will not be printed.
  #   Default is `false`.
  #
  # @return [String] Returns the messages joined by newline characters.
  def self.write(*messages, silent: false)
    puts(*messages) unless silent
    messages.join("\n")
  end

  # PUBLIC INTERFACE FOR `include Say`

  # rubocop:disable Style/SingleLineMethods

  # @see .call Forwards to Say.call
  def say(...) Say.(...) end
  # @see .line Forwards to Say.line
  def say_line(...) Say.line(...) end
  # @see .with_block Forwards to Say.with_block
  def say_with_block(...) Say.with_block(...) end
  # @see .header Forwards to Say.header
  def say_header(...) Say.header(...) end
  # @see .footer Forwards to Say.footer
  def say_footer(...) Say.footer(...) end
  # @see .banner Forwards to Say.banner
  def say_banner(...) Say.banner(...) end
  # @see .progress Aliases Say.progress
  def say_progress(...) Say.progress(...) end
  # @see .progress_line Aliases Say.progress_line
  def say_progress_line(...) Say.progress_line(...) end

  # rubocop:enable Style/SingleLineMethods

  # :nocov:

  # Usage: Say.test;
  # @!visibility private
  def self.test
    Say::LJBanner.test
    Say::InterpolationTemplate.test
    Say::Progress::Interval.test
    Say::Progress::Tracker.test
  end

  # :nocov:
end

# Empty namespace holder.
module Say::Progress
end

require "say/interpolation_template"
require "say/banners/lj_banner"
require "say/progress/tracker"
require "say/progress/interval"
require "say/time"
