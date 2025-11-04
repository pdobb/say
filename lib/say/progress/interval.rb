# frozen_string_literal: true

# Say::Progress::Interval represents a yielded object (for {Say.progress}) which
# can be used to say (or not say) progress updates on a given Interval. The
# interval is defined by and tracked by the passed in {Say::Progress::Tracker}
# object.
#
# An interval, in this context, is a predefined number of iterations through a
# loop on which to update progress. If the current loop index is on-interval
# (i.e. if {#tick?} is true), then Say output will be written. Else, no Say
# output will be written. This allows for less spammy progress updates over
# time during long processing loops.
#
# @see Say::Progress::Tracker
# @see Say.progress
class Say::Progress::Interval
  attr_reader :tracker

  def initialize(tracker: Say::Progress::Tracker.new)
    @tracker = tracker
  end

  # Print something via {Say.progress} (if a block is given) or {Say.call} (if
  # no block is given) if this is an on-interval tick. If a block is given it
  # will always be called, regardless.
  #
  # @param text [String] The message to be printed.
  # @param type [Symbol] The type of the message.
  #   (see Say::Message::TYPES)
  #   Note: `type` is ignored if a block is given.
  # @param block [Proc] A block of code to be called with header and footer
  #   banners.
  #
  # @return [] Returns the result of the called block if a block is given.
  def say(text = nil, type = nil, index: self.index, &block)
    if tick?
      if block
        Say.progress(text, index:, &block)
      else
        Say.progress_line(text, type, index:)
      end
    elsif block
      yield
    else
      # Nothing to do.
    end
  end

  # Update the current Interval index by either specifying an index or just
  # incrementing it.
  #
  # Must be called manually by the client code because automatic index updating
  # is less reliable.
  #
  # @param index [Integer, nil] The current index number we're on for this
  #   Interval.
  #
  # @return [self]
  def update(index = nil)
    if index
      tracker.update(index)
    else
      tracker.increment
    end

    self
  end

  private

  def tick?
    tracker.tick?
  end

  def index
    tracker.index
  end

  # rubocop:disable all
  # :nocov:
  # @!visibility private

  # Usage: Say::Progress::Interval.test;
  def self.test
    require "timecop"
    Timecop.freeze(Say::Time.test_sample)

    Say.("Say::Progress::Interval.test") do
      tracker = Say::Progress::Tracker.new(interval: 2)

      results = []
      Say::Progress::Interval.new(tracker: tracker).tap { |interval|
        results.append(
          interval.say("T", :debug),
          interval.update.say("nope.", :error),
          interval.update.say("E") { Say.("S", :info) },
          interval.say("T"),
        )
      }

      expected_results = [
        nil,
        nil,
        " -- S",
        "[12340506123456]  -> T (i=2)",
      ]

      if results == expected_results
        ap(["✅", results])
      else
        ap(["❌", { "Got:" => results, "Expected:" => expected_results }])
      end
    end

    Timecop.return
  end

  # :nocov:
  # rubocop:enable all
end
