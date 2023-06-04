# frozen_string_literal: true

# Play from the Pry console with:
#   play script/readme.rb

require "yaml"

require "timecop"
Timecop.freeze(Say::Time.test_sample)

################################################################################
# `include Say`
################################################################################
Say.call do
  class IncludeProcessor
    include Say

    def run
      say("IncludeProcessor") {
        say("Successfully did the thing!")
        say
        say("Debug details about this ...", :debug)
        say("Info about stuff ...", :info)
        say("Maybe look into this thing ...", :warn)
        say("Failed to do a thing ...", :error)

        "The Result!"
      }
    end
  end

  result = IncludeProcessor.new.run
  # ...
  result
end

################################################################################
# `Say.<method>`
################################################################################
Say.banner; Say.banner; Say.footer(nil)

Say.call do
  class DirectAccessProcessor
    def run
      Say.("DirectAccessProcessor") {
        Say.("Successfully did the thing!")
        Say.() # Or: Say.call
        Say.("Debug details about this ...", :debug)
        Say.("Info about stuff ...", :info)
        Say.("Maybe look into this thing ...", :warn)
        Say.("Failed to do a thing ...", :error)

        "The Result!"
      }
    end
  end

  result = DirectAccessProcessor.new.run
  # ...
  result
end

################################################################################
# Say Types
################################################################################
Say.banner; Say.banner; Say.footer(nil)

Say.("Say::TYPES") do
  puts(
    Say::TYPES.map { |key, value|
      "#{"`:#{key}`".to_sym} -> #{"`#{value.inspect}`"}"
    }.to_yaml)

  Say.("For example:") do
    Say.("TEST", :debug)
    Say.("TEST", :error)
    Say.("TEST", :info)
    Say.("TEST", :success)
    Say.("TEST", :warn)
  end
end

################################################################################
# Progress Tracking
################################################################################
Say.banner; Say.banner; Say.footer(nil)

# Simple
# The default interval is 1.
Say.progress do |interval|
  3.times do
    # Increment the interval's internal index by 1.
    interval.update

    interval.say("Test", :debug)
  end
end;

# Advanced
Say.progress("Progress Tracking Test", interval: 3) do |interval|
  0.upto(6) do |index|
    # Set the interval's internal index to the current index. This may be safer.
    interval.update(index)

    # Only "say" for on-interval ticks through the loop.
    interval.say("Before Update Interval.", :debug)
    # Optionally use a block to time a segment.
    interval.say("Progress Interval Block.") do
      sleep(0.025) # Do the work here.

      # Always "say", regardless of interval, in the usual way: with `Say.call`.
      Say.("Interval-Agnostic Update. Index: #{index}", :info)
    end
    interval.say("After Update Interval.", :debug)
  end
end;

# Manual
Say.("Manual Usage: Say.progress_line") do
  # Given a message. (The default Type is :info.)
  Say.progress_line("TEST", index: 3)
  Say.progress_line("TEST", :success, index: 3)

  # Given no message.
  Say.progress_line(index: 3)
end

################################################################################
# Namespace Pollution
################################################################################
Say.banner; Say.banner; Say.footer(nil)

Say.("Namespace Pollution") do
  class WithInclude
    include Say
  end

  class WithoutInclude
  end

  added_class_methods = WithInclude.methods - WithoutInclude.methods
  Say.("Class methods added by `include Say`: #{added_class_methods}")

  added_instance_methods = (WithInclude.new.methods - WithoutInclude.new.methods).sort!
  Say.("Instance methods added by `include Say`: #{added_instance_methods}")
  puts(added_instance_methods.map { |im| "`#{im}`".to_sym }.to_yaml)
end;
