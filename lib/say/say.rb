# frozen_string_literal: true

require "benchmark"

# Say is a utility module for printing built messages. It aides in logging
# standardized output that allows for easy scanning and/or highlighting of
# info, debug, warn, error, and success messaging.
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
#   = IncludeProcessor =============================================================
#    -> Successfully did the thing!
#    ...
#    >> Debug details about this ...
#    -- Info about stuff ...
#    !¡ Maybe look into this thing ...
#    ** Failed to do a thing ...
#   = Done (0.0000s) ===============================================================
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
#    ** Failed to do a thing ...
#   = Done (0.0000s) ===============================================================
#
#   result  # => "The Result!"
module Say # rubocop:disable Metrics/ModuleLength
  # The maximum number of columns for message types that support it, e.g.
  # banners.
  MAX_COLUMNS = 80

  # The default template used by {.hr}, if none is provided.
  DEFAULT_HR_TEMPLATE = "\n%s\n"

  # The default message to display in {.footer}s, if none is provided.
  DONE_MESSAGE = "Done"
  # The default message to display in {.progress} blocks, if none is provided.
  START_MESSAGE = "Start"

  # Clears `^C`, which is output when a user presses `ctrl+c`, e.g. during a
  # long-running task.
  CLEAR_OUTPUT_ESC_CODE = "\e[2K\r"

  # Prints either a one-line message of the given type or executes a block of
  # code and surrounds it with header and footer banner messages.
  #
  # @param text [String] The message to be printed.
  # @param type [Symbol] The type of the message.
  #   (see Say::Message::TYPES)
  #   Note: `type` is ignored if a block is given.
  # @param block [Proc] A block of code to be called with header and footer
  #   banners.
  #
  # @return The result of the called block, if a block is given.
  # @return [String] The built message, if no block is given.
  #
  # @example No Block Given
  #   Say.("Hello, World!")  # => " -> Hello, World!"
  #   Say.("Oops", :error)   # => " ** Oops"
  #   Say.()                 # => " ..."
  #
  # @example Given a Block, Left-Justified (Default)
  #   Say.("Hello, World!")  { Say.("Huzzah!") }
  #   = Hello, World! ================================================================
  #    -> Huzzah!
  #   = Done (0.0000s) ===============================================================
  #
  # @example Given a Block, Center-Justified
  #   Say.("Hello, World!", justify: :center) { Say.("Huzzah!") }
  #   ================================ Hello, World! =================================
  #    -> Huzzah!
  #   ================================ Done (0.0000s) ================================
  #
  # @example Given a Block, Right-Justified
  #   Say.("Hello, World!", justify: :right) { Say.("Huzzah!") }
  #   ================================================================ Hello, World! =
  #    -> Huzzah!
  #   =============================================================== Done (0.0000s) =
  def self.call(text = nil, type = nil, **with_block_kwargs, &block)
    if block
      with_block(header: text, **with_block_kwargs, &block)
    else
      line(text, type: type)
    end
  end

  # rubocop:disable Style/SingleLineMethods
  # Output :debug "type" text. Same as `line(text, type: :debug)`.
  def self.debug(text) line(text, type: :debug) end
  # Output :error "type" text. Same as `line(text, type: :error)`.
  def self.error(text) line(text, type: :error) end
  # Output :info "type" text. Same as `line(text, type: :info)`.
  def self.info(text) line(text, type: :info) end
  # Output :success "type" text. Same as `line(text, type: :success)`.
  def self.success(text) line(text, type: :success) end
  # Output :warn "type" text. Same as `line(text, type: :warn)`.
  def self.warn(text) line(text, type: :warn) end
  # rubocop:enable Style/SingleLineMethods

  # Prints a built one-line message of the given type using {Say.write}.
  #
  # @param text [String] The message to be printed.
  # @param message_kwargs [Hash] Additional keyword arguments to be passed to
  #   the `message` method of the same class/module.
  #
  # @return [String] The built message.
  #
  # @example
  #   Say.line("Hello, World!")  # => " -> Hello, World!"
  #   Say.line("Oops", :error)   # => " ** Oops"
  #   Say.line                   # => " ..."
  def self.line(text = nil, **message_kwargs)
    write(Say::Message.new(text, **message_kwargs))
  end

  # Executes a block of code, surrounding it with header and footer banner
  # messages.
  #
  # @param header [String] The message to be printed in the header.
  # @param footer [String] The message to be printed in the footer.
  #   Default is {Say::DONE_MESSAGE}.
  #
  # @yield [] The block of code to be called.
  #
  # @return The result of the called block.
  #
  # @raise [ArgumentError] Raises an ArgumentError if no block is given.
  #
  # @example Left-Justified (Default)
  #   Say.with_block(header: "Start") { Say.("Hello, World!") }
  #   = Start ========================================================================
  #    -> Hello, World!
  #   = Done (0.0000s) ===============================================================
  #
  # @example Center-Justified
  #   Say.with_block(header: "Start", justify: :center) {
  #     Say.("Hello, World!")
  #   }
  #   ==================================== Start =====================================
  #    -> Hello, World!
  #   ================================ Done (0.0000s) ================================
  #
  # @example Right-Justified
  #   Say.with_block(header: "Start", justify: :right) { Say.("Hello, World!") }
  #   ================================================================ Hello, World! =
  #    -> Huzzah!
  #   =============================================================== Done (0.0000s) =
  def self.with_block(header: nil, footer: DONE_MESSAGE, justify: :left, &block)
    raise ArgumentError, "block expected" unless block

    self.header(header, justify: justify)
    result, footer_with_runtime_string = benchmark_block_run(footer, &block)
    self.footer(footer_with_runtime_string, justify: justify)

    result
  end

  def self.benchmark_block_run(message)
    result = nil
    time = Benchmark.measure { result = yield }
    time_string = "%.4fs" % time.real
    [result, "#{message} (#{time_string})"]
  end
  private_class_method :benchmark_block_run

  # :reek:TooManyStatements

  # Prints a horizontal rule (just a simple line), like the `<hr>` tag in HTML.
  #
  # @param columns [Integer] The maximum length of the horizontal line.
  #   Default value is the constant `MAX_COLUMNS`.
  #
  # @return [String] The horizontal rule String.
  #
  # rubocop:disable Layout/LineLength
  # @example Default usage
  #   Say.hr
  #
  #   --------------------------------------------------------------------------------
  #
  #   # => "--------------------------------------------------------------------------------"
  # rubocop:enable Layout/LineLength
  #
  # @example Custom columns (length)
  #   Say.hr(columns: 20)
  #
  #   --------------------
  #
  #   # => "--------------------"
  #
  # @example Custom fill
  #   Say.hr("-*-++", columns: 20)
  #
  #   -*-++-*-++-*-++-*-++
  #
  #   # => "-*-++-*-++-*-++-*-++"
  #
  # @example Custom template ()
  #   Say.hr("-*-++", template: "%s", columns: 20)
  #   -*-++-*-++-*-++-*-++
  #   # => "-*-++-*-++-*-++-*-++"
  def self.hr(fill = "-", template: DEFAULT_HR_TEMPLATE, columns: MAX_COLUMNS)
    filler = (fill * columns)

    truncate_at =
      if template == DEFAULT_HR_TEMPLATE
        columns
      else
        # Truncate `filler` enough so that any non-whitespace
        # (`\n`), non-template(`%s`) characters can be included in the
        # horizontal rule without causing the final result to exceed `columns`
        # in length.
        # rubocop:disable Performance/StringReplacement
        non_template_characters_count =
          template.gsub("\n", "").gsub("%s", "").length
        # rubocop:enable Performance/StringReplacement
        columns - non_template_characters_count
      end

    write(template % filler[...truncate_at]).tap {
      # Make it so `\n` at the beginning and `\n` at the end of the template
      # behave the same: They both create a single empty line in the output--as
      # one would expect.
      write("\n") if template.end_with?("\n")
    }.strip
  end

  # Prints a header banner (using {.write}) that fills at least the passed in
  # `columns` number of columns. This serves as, e.g., a visual break point at
  # the start of a processing task.
  #
  # @param text [String] The message to be printed as the header.
  # @param banner_kwargs [Hash] Additional keyword arguments to be passed to the
  #   `banner` method of the same class/module.
  # @option banner_kwargs [Integer] :columns The maximum *preferred* column
  #   length of the header message.
  # @option banner_kwargs [Symbol] :justify The text justification to use for
  #   the banner.
  #
  # @return [String] The built banner message.
  #
  # @example Default (though non-standard) usage
  #   Say.header
  #   # => "================================================================================"
  #
  # @example Custom (standard) usage
  #   Say.header("Head")
  #   # => "= Head ========================================================================="
  #
  #   Say.header("Head", columns: 20)
  #   # => "= Head ============="
  def self.header(text = nil, **banner_kwargs)
    banner(text, **banner_kwargs)
  end

  # Prints a footer banner (using {Say.write}) that fills at least the passed in
  # `columns` number of columns. This serves as, e.g., a visual break
  # point at the end of a processing task.
  #
  # @param text [String] The message to be printed as the footer.
  # @param banner_kwargs [Hash] Additional keyword arguments to be passed to the
  #   `banner` method of the same class/module.
  # @option banner_kwargs [Integer] :columns The maximum *preferred* column
  #   length of the header message.
  # @option banner_kwargs [Symbol] :justify The text justification to use for
  #   the banner.
  #
  # @return [String] The built banner message.
  #
  # @example Default usage
  #   Say.footer
  #   # => "= Done =========================================================================\n\n"
  #
  # @example Custom usage
  #   Say.footer("Foot", columns: 20)
  #   # => "= Foot =============\n\n"
  #
  #   Say.footer("Foot", columns: 20, justify: :center)
  #   # => "======= Foot =======\n\n"
  #
  #   Say.footer("Foot", columns: 20, justify: :right)
  #   # => "============= Foot =\n\n"
  def self.footer(text = DONE_MESSAGE, **banner_kwargs)
    result = banner(text, **banner_kwargs)
    write("\n")
    result
  end

  # Prints a banner String with the specified message using {Say.write}. If no
  # message is supplied, just prints a full-width banner String.
  #
  # @param text [String] The message to be included in the banner.
  # @param columns [Integer] The maximum length of the banner line.
  #   Default value is the constant `MAX_COLUMNS`.
  #
  # @return [String] The formatted banner String.
  #
  # @example Default usage
  #   Say.banner
  #   # => "================================================================================"
  #
  # @example Custom usage
  #   Say.banner("Test", columns: 20)
  #   # => "= Test ============="
  #
  #   Say.banner("Test", columns: 20, justify: :center)
  #   # => "======= Test ======="
  #
  #   Say.banner("Test", columns: 20, justify: :right)
  #   # => "============= Test ="
  def self.banner(text = nil, columns: MAX_COLUMNS, justify: :left)
    write(Say::BannerGenerator.(text, columns: columns, justify: justify))
  end

  # Prints a set of 3 banner Strings with the specified message using
  # {Say.write}. If no message is supplied, just prints 3 full-width banner
  # String. The final banner string is printed using {Say.footer}, so includes
  # an extra newline character.
  #
  # @param text [String] The message to be included in the 2nd banner.
  # @param columns [Integer] The maximum length of the banner lines.
  #   Default value is the constant `MAX_COLUMNS`.
  #
  # @return [String] The formatted banner String.
  #
  # @example Default usage
  #   Say.section  # =>
  #   ================================================================================
  #   ================================================================================
  #   ================================================================================
  #
  # @example Custom usage
  #   Say.section("Test", columns: 20)  # =>
  #   ====================
  #   = Test =============
  #   ====================
  #
  #   Say.section("Test", columns: 20, justify: :center)  # =>
  #   ====================
  #   ======= Test =======
  #   ====================
  #
  #   Say.section("Test", columns: 20, justify: :right)  # =>
  #   ====================
  #   ============= TEST =
  #   ====================
  #
  # :reek:DuplicateMethodCall
  def self.section(text = nil, columns: MAX_COLUMNS, justify: :left)
    banner = Say::BannerGenerator.(text, columns: columns, justify: justify)
    decorative_banner =
      Say::BannerGenerator.(nil, columns: banner.length, justify: :left)

    [
      write(decorative_banner),
      write(banner),
      write(decorative_banner).tap { write("\n") },
    ]
  end

  # Builds a {Say::Progress::Tracker} and yields an associated
  # {Say::Progress::Interval} the user-supplied block for printing `say`
  # messages only for on-interval ticks through the loop.
  #
  # @param text [String] The String to be printed in the header banner.
  #
  # @yield [Say::Progress::Interval] The interval upon which to `say` things.
  #
  # @return The result of the called block.
  #
  # @example A Simple Example
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
  def self.progress(text = START_MESSAGE, **kwargs, &block)
    tracker = Say::Progress::Tracker.new(**kwargs)

    header = progress_message(text, index: tracker.index)

    with_block(header: header) do
      tracker.call(&block)
    end
  end

  # Prints a {.progress_message} (one that includes the original text plus an
  # indicator of the given `index`) via {Say.say}.
  #
  # @param text [String] The String to be printed, which will be appended with
  #   an indicator of the given `index`.
  # @param type [Symbol] The type of the message. (see Say::Message::TYPES)
  # @param index [Integer]
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
    message = Say::Message.new(text, type: type)
    full_message = progress_message(message, index: index)

    write(full_message)
  end

  # @param message [Say::Message, #to_s] The message text to be output.
  #
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
  #
  # @return [String] The messages, joined by newline characters.
  def self.write(*messages)
    puts(*messages)
    messages.join("\n")
  end

  # Clear `^C` interrupt output.
  #
  # @example
  #   Say.clear_esc.warn("...")
  #
  # @return [self]
  def self.clear_esc
    puts(CLEAR_OUTPUT_ESC_CODE)
    self
  end

  # PUBLIC INTERFACE FOR `include Say`

  # rubocop:disable Style/SingleLineMethods

  # @see .call Forwards to Say.call
  def say(...) Say.(...) end
  # @see .line Forwards to Say.line
  def say_line(...) Say.line(...) end
  # @see .with_block Forwards to Say.with_block
  def say_with_block(...) Say.with_block(...) end
  # @see .hr Forwards to Say.hr
  def say_hr(...) Say.hr(...) end
  # @see .header Forwards to Say.header
  def say_header(...) Say.header(...) end
  # @see .footer Forwards to Say.footer
  def say_footer(...) Say.footer(...) end
  # @see .banner Forwards to Say.banner
  def say_banner(...) Say.banner(...) end
  # @see .section Forwards to Say.section
  def say_section(...) Say.section(...) end
  # @see .progress Forwards to Say.progress
  def say_progress(...) Say.progress(...) end
  # @see .progress_line Forwards to Say.progress_line
  def say_progress_line(...) Say.progress_line(...) end

  # rubocop:enable Style/SingleLineMethods

  # :nocov:
  # @!visibility private

  # Usage: Say.test;
  def self.test
    Say::InterpolationTemplate.test
    Say.hr(template: "%s\n")
    Say::Progress::Interval.test
    Say.hr(template: "%s\n")
    Say::Progress::Tracker.test
  end

  # :nocov:
end
